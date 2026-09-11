#!/usr/bin/env python3
"""Valida la integridad del catálogo geológico empaquetado en assets/data.

El contenido de esta aplicación es didáctico: un ejercicio con dos respuestas
correctas o una referencia cruzada rota no rompe la compilación, pero sí
enseña algo equivocado. Por eso se valida en CI igual que el código.

Uso:
    python tool/validate_content.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "assets" / "data"

LUSTER = {"metalico", "no_metalico"}
CLEAVAGE = {"ninguno", "regular", "perfecto"}
MODULES = {"identificacion", "clasificacion", "estructuras"}
ROCK_TYPES = {"ignea_intrusiva", "ignea_extrusiva", "sedimentaria", "metamorfica"}

errors: list[str] = []
warnings: list[str] = []


def load(name: str) -> list[dict]:
    path = DATA / name
    if not path.exists():
        errors.append(f"{name}: el archivo no existe")
        return []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append(f"{name}: JSON inválido ({exc})")
        return []
    if not isinstance(data, list):
        errors.append(f"{name}: se esperaba una lista en la raíz")
        return []
    return data


def check_unique_ids(name: str, items: list[dict]) -> set[str]:
    seen: set[str] = set()
    for item in items:
        item_id = item.get("id")
        if not item_id:
            errors.append(f"{name}: hay un registro sin 'id'")
            continue
        if item_id in seen:
            errors.append(f"{name}: id duplicado '{item_id}'")
        seen.add(item_id)
    return seen


def check_one_correct(label: str, options: list[dict]) -> None:
    if len(options) < 2:
        errors.append(f"{label}: necesita al menos dos alternativas")
    correct = [o for o in options if o.get("correct") is True]
    if len(correct) != 1:
        errors.append(
            f"{label}: tiene {len(correct)} alternativas correctas, debe tener 1"
        )
    option_ids = [o.get("id") for o in options]
    if len(set(option_ids)) != len(option_ids):
        errors.append(f"{label}: ids de alternativa duplicados")


def main() -> int:
    minerals = load("minerals.json")
    rocks = load("rocks.json")
    structures = load("structures.json")
    exercises = load("exercises.json")
    cases = load("cases.json")

    mineral_ids = check_unique_ids("minerals.json", minerals)
    rock_ids = check_unique_ids("rocks.json", rocks)
    structure_ids = check_unique_ids("structures.json", structures)
    check_unique_ids("exercises.json", exercises)
    check_unique_ids("cases.json", cases)

    catalog_ids = mineral_ids | rock_ids | structure_ids

    # --- Minerales -------------------------------------------------------
    for m in minerals:
        ref = f"minerals.json/{m.get('id')}"
        if m.get("luster") not in LUSTER:
            errors.append(f"{ref}: brillo inválido '{m.get('luster')}'")
        if m.get("cleavage") not in CLEAVAGE:
            errors.append(f"{ref}: clivaje inválido '{m.get('cleavage')}'")
        h_min, h_max = m.get("hardnessMin"), m.get("hardnessMax")
        if not isinstance(h_min, (int, float)) or not isinstance(h_max, (int, float)):
            errors.append(f"{ref}: dureza no numérica")
        elif not (1 <= h_min <= h_max <= 10):
            errors.append(f"{ref}: rango de dureza fuera de la escala de Mohs")
        sg = m.get("specificGravity")
        if not isinstance(sg, (int, float)) or not (1 < sg < 25):
            errors.append(f"{ref}: peso específico implausible ({sg})")
        color = str(m.get("displayColor", ""))
        if not (color.startswith("#") and len(color) == 7):
            errors.append(f"{ref}: displayColor debe ser #RRGGBB")
        if not m.get("diagnostic"):
            errors.append(f"{ref}: sin criterios diagnósticos")
        if not m.get("miningRelevance"):
            errors.append(f"{ref}: sin relevancia minera declarada")
        for other in m.get("confusedWith", []):
            if other not in mineral_ids:
                # No es un error: el catálogo del MVP es parcial y estas
                # etiquetas se muestran como texto, no como enlace.
                warnings.append(
                    f"{ref}: confusión con '{other}', que no está en el catálogo"
                )

    # Toda banda de dureza y densidad debe contener al menos un mineral, o el
    # determinador tendría opciones que nunca devuelven nada.
    bands = [("muyBlanda", 1.0, 2.5), ("blanda", 2.5, 3.5),
             ("media", 3.5, 5.5), ("dura", 5.5, 10.0)]
    for label, low, high in bands:
        hit = [m for m in minerals
               if isinstance(m.get("hardnessMin"), (int, float))
               and m["hardnessMin"] <= high and m["hardnessMax"] >= low]
        if not hit:
            errors.append(f"minerals.json: la banda de dureza '{label}' está vacía")

    for label, low, high in [("ligera", 0.0, 3.0), ("media", 3.0, 4.5),
                             ("pesada", 4.5, 25.0)]:
        hit = [m for m in minerals
               if isinstance(m.get("specificGravity"), (int, float))
               and low <= m["specificGravity"] <= high]
        if not hit:
            errors.append(f"minerals.json: la banda de densidad '{label}' está vacía")

    # --- Rocas -----------------------------------------------------------
    for r in rocks:
        ref = f"rocks.json/{r.get('id')}"
        if r.get("type") not in ROCK_TYPES:
            errors.append(f"{ref}: tipo de roca inválido '{r.get('type')}'")
        if not r.get("identificationKeys"):
            errors.append(f"{ref}: sin claves de identificación")
        if not r.get("miningContext"):
            errors.append(f"{ref}: sin contexto minero")

    # --- Estructuras -----------------------------------------------------
    for s in structures:
        ref = f"structures.json/{s.get('id')}"
        if not s.get("recognitionKeys"):
            errors.append(f"{ref}: sin claves de reconocimiento")
        if not s.get("miningImplication"):
            errors.append(f"{ref}: sin implicancia minera")

    # --- Ejercicios ------------------------------------------------------
    for e in exercises:
        ref = f"exercises.json/{e.get('id')}"
        if e.get("module") not in MODULES:
            errors.append(f"{ref}: módulo inválido '{e.get('module')}'")
        if e.get("difficulty") not in (1, 2, 3):
            errors.append(f"{ref}: dificultad fuera de rango")
        if not e.get("context"):
            errors.append(f"{ref}: sin escena profesional (campo 'context')")
        if not e.get("explanation"):
            errors.append(f"{ref}: sin explicación")
        check_one_correct(ref, e.get("options", []))
        for rid in e.get("relatedIds", []):
            if rid not in catalog_ids:
                errors.append(f"{ref}: relatedId inexistente '{rid}'")

    for module in MODULES:
        count = len([e for e in exercises if e.get("module") == module])
        if count < 4:
            errors.append(
                f"exercises.json: el módulo '{module}' solo tiene {count} "
                "ejercicios; una sesión necesita al menos 4"
            )

    # --- Casos -----------------------------------------------------------
    for c in cases:
        ref = f"cases.json/{c.get('id')}"
        steps = c.get("steps", [])
        if len(steps) < 2:
            errors.append(f"{ref}: un caso encadenado necesita al menos 2 etapas")
        step_ids = [s.get("id") for s in steps]
        if len(set(step_ids)) != len(step_ids):
            errors.append(f"{ref}: ids de etapa duplicados")
        for s in steps:
            check_one_correct(f"{ref}/{s.get('id')}", s.get("options", []))
            if not s.get("narrative"):
                errors.append(f"{ref}/{s.get('id')}: sin información de campo")
            if not s.get("explanation"):
                errors.append(f"{ref}/{s.get('id')}: sin explicación")

    # --- Reporte ---------------------------------------------------------
    print(f"Minerales:   {len(minerals)}")
    print(f"Rocas:       {len(rocks)}")
    print(f"Estructuras: {len(structures)}")
    print(f"Ejercicios:  {len(exercises)}")
    print(f"Casos:       {len(cases)} "
          f"({sum(len(c.get('steps', [])) for c in cases)} decisiones)")
    print()

    if warnings:
        print(f"Advertencias ({len(warnings)}):")
        for w in warnings[:10]:
            print(f"  - {w}")
        if len(warnings) > 10:
            print(f"  ... y {len(warnings) - 10} más")
        print()

    if errors:
        print(f"ERRORES ({len(errors)}):")
        for e in errors:
            print(f"  - {e}")
        return 1

    print("Contenido válido.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
