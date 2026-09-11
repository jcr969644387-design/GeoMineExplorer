import '../../domain/entities/guide_topic.dart';

/// Guia tecnica de referencia de la aplicacion.
///
/// A diferencia del catalogo, este contenido no se lee de `assets/data`: no
/// cambia con el tiempo, no se filtra ni se busca y ningun ejercicio lo
/// referencia. Escribirlo como constante evita montar un parser, un mapper y
/// un repositorio para un texto que es, literalmente, el mismo cada vez.
const List<GuideTopic> kFieldGuide = <GuideTopic>[
  GuideTopic(
    id: 'dureza',
    title: 'Dureza y escala de Mohs',
    summary: 'Los diez patrones y con qué se prueba cada uno sin laboratorio.',
    sections: <GuideSection>[
      GuideSection(
        heading: 'La escala',
        body: 'Es una escala ordinal, no proporcional: mide qué raya a qué, '
            'no cuánto más duro es. La diferencia real entre el corindón (9) '
            'y el diamante (10) es mayor que la que hay entre el talco (1) y '
            'el corindón.',
        rows: <GuideRow>[
          GuideRow('1 · Talco', 'Se raya con la uña, tacto jabonoso'),
          GuideRow('2 · Yeso', 'Se raya con la uña'),
          GuideRow('3 · Calcita', 'Se raya con una moneda de cobre'),
          GuideRow('4 · Fluorita', 'Se raya con facilidad con un clavo'),
          GuideRow('5 · Apatito', 'Se raya con dificultad con un clavo'),
          GuideRow('6 · Ortoclasa', 'Raya el vidrio, la lima la raya a ella'),
          GuideRow('7 · Cuarzo', 'Raya el vidrio y el acero con facilidad'),
          GuideRow('8 · Topacio', 'Raya el cuarzo'),
          GuideRow('9 · Corindón', 'Raya el topacio'),
          GuideRow('10 · Diamante', 'Raya todo lo anterior'),
        ],
      ),
      GuideSection(
        heading: 'Instrumentos que sí se llevan al campo',
        rows: <GuideRow>[
          GuideRow('Uña', '2,2'),
          GuideRow('Moneda de cobre', '3,5'),
          GuideRow('Clavo o punta de acero', '5,5'),
          GuideRow('Vidrio de ventana', '5,5'),
          GuideRow('Lima de acero', '6,5'),
          GuideRow('Porcelana sin vidriar', '6,5'),
        ],
      ),
      GuideSection(
        heading: 'Errores que invalidan la prueba',
        bullets: <String>[
          'Confundir el polvo del instrumento con una raya real: se limpia con '
              'el dedo y se vuelve a mirar. Si la marca desaparece, no hubo '
              'rayado.',
          'Probar sobre una costra de alteración en lugar de sobre la '
              'superficie fresca de la muestra.',
          'Rayar un agregado terroso: mide la cohesión del agregado, no la '
              'dureza del mineral.',
          'Dar un valor exacto de Mohs a partir de una prueba de campo. Lo '
              'honesto es declarar un rango.',
        ],
      ),
    ],
  ),
  GuideTopic(
    id: 'pruebas',
    title: 'Protocolo de las pruebas determinativas',
    summary: 'Cómo se ejecuta cada prueba y qué resultado es válido.',
    sections: <GuideSection>[
      GuideSection(
        heading: 'Raya',
        body: 'Se frota la muestra contra porcelana sin vidriar. Es la prueba '
            'más estable de todas porque el color del polvo no depende del '
            'tamaño del grano ni de la pátina superficial. Solo funciona en '
            'minerales de dureza menor a 6,5: por encima, la porcelana se '
            'raya a sí misma y deja polvo blanco engañoso.',
      ),
      GuideSection(
        heading: 'Brillo',
        body: 'Primera bifurcación de cualquier clave. Se observa sobre una '
            'superficie fresca y con luz indirecta.',
        bullets: <String>[
          'Metálico: refleja como un metal pulido y es opaco incluso en '
              'lámina delgada.',
          'Submetálico: metálico apagado, típico de superficies alteradas.',
          'No metálico: vítreo, resinoso, nacarado, sedoso, graso o terroso.',
        ],
      ),
      GuideSection(
        heading: 'Clivaje y fractura',
        body: 'El clivaje es la rotura por planos de debilidad de la '
            'estructura cristalina y se repite siempre en las mismas '
            'direcciones; la fractura es la rotura irregular que ocurre '
            'cuando no hay tales planos. Se cuentan las direcciones de '
            'clivaje y el ángulo entre ellas, no el número de caras.',
        bullets: <String>[
          'Una dirección: micas.',
          'Dos a 90 grados: feldespatos y piroxenos.',
          'Tres a 90 grados (cúbico): galena y halita.',
          'Tres no a 90 grados (romboédrico): calcita.',
          'Cuatro (octaédrico): fluorita.',
        ],
      ),
      GuideSection(
        heading: 'Peso específico',
        body: 'En campo se estima sopesando la muestra y comparándola con un '
            'trozo de roca común del mismo tamaño. Un salto claro de peso '
            'para un volumen pequeño delata sulfuros de metales pesados.',
        rows: <GuideRow>[
          GuideRow('Liviana', 'Menor a 3,0 · silicatos y carbonatos'),
          GuideRow('Corriente', '3,0 a 4,5 · sulfatos, óxidos livianos'),
          GuideRow('Pesada', 'Mayor a 4,5 · sulfuros, óxidos de hierro'),
        ],
      ),
      GuideSection(
        heading: 'Reacción con ácido clorhídrico',
        body: 'Una gota de HCl diluido al 10 % en frío sobre superficie '
            'fresca. La calcita efervesce de inmediato; la dolomita solo lo '
            'hace en polvo o en caliente. Se trabaja con gafas y guantes, con '
            'la muestra apoyada y nunca en la mano.',
      ),
      GuideSection(
        heading: 'Magnetismo y tenacidad',
        bullets: <String>[
          'El imán se acerca a la muestra, no al revés, y se prueba en varios '
              'puntos: la magnetita atrae siempre, la pirrotita solo a veces.',
          'Tenacidad: frágil se rompe, séctil se corta con navaja, maleable se '
              'aplana a golpes, flexible se dobla y no recupera la forma, '
              'elástica se dobla y sí la recupera.',
        ],
      ),
    ],
  ),
  GuideTopic(
    id: 'igneas',
    title: 'Clasificación de las rocas ígneas',
    summary: 'Composición y textura: las dos preguntas que resuelven el '
        'nombre.',
    sections: <GuideSection>[
      GuideSection(
        heading: 'Por composición y profundidad',
        body: 'La misma composición da dos rocas distintas según dónde '
            'cristalizó: lenta y en profundidad (plutónica, grano grueso) o '
            'rápida y en superficie (volcánica, grano fino).',
        rows: <GuideRow>[
          GuideRow('Félsica · más de 69 % SiO₂', 'Granito / Riolita'),
          GuideRow('Intermedia · 63-69 %', 'Granodiorita / Dacita'),
          GuideRow('Intermedia · 52-63 %', 'Diorita / Andesita'),
          GuideRow('Máfica · 45-52 %', 'Gabro / Basalto'),
          GuideRow('Ultramáfica · menos de 45 %', 'Peridotita / Komatiita'),
        ],
      ),
      GuideSection(
        heading: 'Por textura',
        rows: <GuideRow>[
          GuideRow('Fanerítica', 'Todos los cristales visibles a simple vista'),
          GuideRow('Afanítica', 'Cristales no resolubles sin lupa'),
          GuideRow('Porfídica', 'Fenocristales sobre matriz fina: dos etapas'),
          GuideRow('Vítrea', 'Sin cristales, enfriamiento instantáneo'),
          GuideRow('Vesicular', 'Huecos de gas atrapado'),
          GuideRow('Piroclástica', 'Fragmentos expulsados y soldados'),
          GuideRow('Pegmatítica', 'Cristales centimétricos, fase residual'),
        ],
      ),
      GuideSection(
        heading: 'Por qué importa en minería',
        body: 'La roca huésped condiciona todo lo que viene después: la '
            'granodiorita y la diorita hospedan la mayoría de los pórfidos de '
            'cobre andinos, las secuencias volcánicas andesíticas alojan los '
            'sistemas epitermales de oro y plata, y la toba, blanda y '
            'arcillosa, es la que obliga a reforzar el sostenimiento.',
      ),
    ],
  ),
  GuideTopic(
    id: 'sedimentarias',
    title: 'Sedimentarias y metamórficas',
    summary: 'Tamaño de grano, origen y grado metamórfico.',
    sections: <GuideSection>[
      GuideSection(
        heading: 'Detríticas, por tamaño de grano',
        rows: <GuideRow>[
          GuideRow('Conglomerado / Brecha', 'Clastos mayores a 2 mm'),
          GuideRow('Arenisca', '0,06 a 2 mm'),
          GuideRow('Limolita', '0,004 a 0,06 mm'),
          GuideRow('Lutita / Arcillita', 'Menor a 0,004 mm'),
        ],
      ),
      GuideSection(
        heading: 'Químicas y bioquímicas',
        rows: <GuideRow>[
          GuideRow('Caliza', 'Calcita; efervesce con HCl en frío'),
          GuideRow('Dolomía', 'Dolomita; efervesce solo en polvo o caliente'),
          GuideRow('Chert', 'Sílice microcristalina, dureza 7'),
          GuideRow('Evaporitas', 'Yeso, anhidrita y halita'),
          GuideRow('Carbón', 'Materia orgánica litificada'),
        ],
      ),
      GuideSection(
        heading: 'Metamórficas foliadas, por grado creciente',
        body: 'La secuencia se lee como un termómetro: a más presión y '
            'temperatura, granos más gruesos y foliación más marcada.',
        rows: <GuideRow>[
          GuideRow('Pizarra', 'Grado bajo, clivaje pizarroso, grano invisible'),
          GuideRow('Filita', 'Brillo sedoso, micas incipientes'),
          GuideRow('Esquisto', 'Grado medio, micas bien visibles'),
          GuideRow('Gneis', 'Grado alto, bandeado claro y oscuro'),
          GuideRow('Migmatita', 'Fusión parcial: transición a roca ígnea'),
        ],
      ),
      GuideSection(
        heading: 'Metamórficas no foliadas',
        rows: <GuideRow>[
          GuideRow('Mármol', 'De caliza; calcita recristalizada'),
          GuideRow('Cuarcita', 'De arenisca; la fractura corta los granos'),
          GuideRow('Corneana', 'De aureola de contacto; dura y masiva'),
          GuideRow('Skarn', 'Metasomatismo de calizas junto al intrusivo'),
        ],
      ),
    ],
  ),
  GuideTopic(
    id: 'alteraciones',
    title: 'Alteraciones hidrotermales',
    summary: 'Qué mineral de alteración indica qué distancia al centro del '
        'sistema.',
    sections: <GuideSection>[
      GuideSection(
        heading: 'Zonas de alteración de un pórfido',
        body: 'Las alteraciones se ordenan como capas de cebolla alrededor '
            'del intrusivo. Reconocer en qué capa se está es lo que permite '
            'decidir hacia dónde perforar.',
        rows: <GuideRow>[
          GuideRow(
            'Potásica',
            'Biotita secundaria y feldespato potásico · núcleo del sistema',
          ),
          GuideRow(
            'Fílica',
            'Cuarzo, sericita y pirita · halo intermedio, alta pirita',
          ),
          GuideRow(
            'Argílica intermedia',
            'Caolinita, clorita e illita · borde del sistema',
          ),
          GuideRow(
            'Argílica avanzada',
            'Alunita, pirofilita y caolinita · alta sulfuración, somero',
          ),
          GuideRow(
            'Propilítica',
            'Clorita, epidota y calcita · exterior, baja temperatura',
          ),
          GuideRow(
            'Silicificación',
            'Sílice masiva o vuggy silica · conductos de mayor ley',
          ),
        ],
      ),
      GuideSection(
        heading: 'Lectura en el mapeo',
        bullets: <String>[
          'La clorita y la epidota verdes son la señal de que se está lejos '
              'del centro: hay sistema, pero no en ese punto.',
          'La sericita blanca y untuosa acompañada de pirita abundante marca '
              'el halo fílico, con ley variable y mucho sulfuro de hierro.',
          'La biotita secundaria, parda y de grano fino sobre la roca, indica '
              'el núcleo potásico: la zona de mayor interés.',
          'La alunita rosada o blanca en vetillas señala alta sulfuración, con '
              'enargita y penalización por arsénico.',
        ],
      ),
    ],
  ),
  GuideTopic(
    id: 'estructural',
    title: 'Rumbo, buzamiento y potencia',
    summary: 'Cómo se registra una estructura para que otro la encuentre.',
    sections: <GuideSection>[
      GuideSection(
        heading: 'Definiciones',
        rows: <GuideRow>[
          GuideRow(
            'Rumbo',
            'Dirección de la línea horizontal contenida en el plano',
          ),
          GuideRow(
            'Buzamiento',
            'Ángulo máximo de inclinación, perpendicular al rumbo',
          ),
          GuideRow(
            'Dirección de buzamiento',
            'Azimut hacia donde cae el plano; rumbo más 90 grados',
          ),
          GuideRow(
            'Potencia real',
            'Espesor medido perpendicular a las cajas',
          ),
          GuideRow(
            'Potencia aparente',
            'La que se ve en la labor; siempre igual o mayor a la real',
          ),
        ],
      ),
      GuideSection(
        heading: 'Notación',
        body: 'Dos convenciones conviven y mezclarlas es el origen de la '
            'mitad de los errores de un mapeo: N45E 60SE (rumbo, buzamiento y '
            'cuadrante) o 135/60 (dirección de buzamiento y buzamiento). Se '
            'elige una para toda la campaña y se declara en la leyenda.',
      ),
      GuideSection(
        heading: 'Buenas prácticas de medición',
        bullets: <String>[
          'Medir sobre superficie plana y fresca, nunca sobre bloque suelto.',
          'Alejar la brújula de la barra de sostenimiento, del casco y del '
              'teléfono: el hierro desvía la lectura varios grados.',
          'Tomar tres medidas de la misma estructura y quedarse con la moda, '
              'no con la primera.',
          'Registrar siempre la declinación magnética del lugar y la fecha.',
          'Convertir la potencia aparente a real con el ángulo entre la labor '
              'y la estructura antes de estimar tonelaje.',
        ],
      ),
    ],
  ),
  GuideTopic(
    id: 'glosario',
    title: 'Glosario minero-geológico',
    summary: 'Los términos que aparecen en un informe y no en el diccionario.',
    sections: <GuideSection>[
      GuideSection(
        heading: 'Recurso y valor',
        rows: <GuideRow>[
          GuideRow('Mena', 'Mineral del que se extrae el metal con beneficio'),
          GuideRow('Ganga', 'Mineral acompañante sin valor económico'),
          GuideRow('Ley', 'Concentración del metal: % , g/t u oz/t'),
          GuideRow(
            'Ley de corte',
            'Ley mínima que paga el costo de extraer y tratar',
          ),
          GuideRow(
            'Dilución',
            'Estéril que entra al material enviado a planta',
          ),
          GuideRow(
            'Recurso y reserva',
            'El recurso es geológico; la reserva es la parte económica y '
                'legalmente extraíble',
          ),
        ],
      ),
      GuideSection(
        heading: 'Geología del yacimiento',
        rows: <GuideRow>[
          GuideRow('Paragénesis', 'Secuencia y asociación de minerales'),
          GuideRow('Gossan', 'Sombrero de hierro: oxidación sobre sulfuros'),
          GuideRow(
            'Enriquecimiento supergénico',
            'Zona de mayor ley bajo la oxidación',
          ),
          GuideRow('Clavo mineralizado', 'Tramo de ley alta dentro de la veta'),
          GuideRow('Caja techo y caja piso', 'Rocas sobre y bajo la veta'),
          GuideRow('Apófisis', 'Ramificación menor de un cuerpo intrusivo'),
        ],
      ),
      GuideSection(
        heading: 'Labor y terreno',
        rows: <GuideRow>[
          GuideRow('Panizo', 'Arcilla de falla, muy débil y plástica'),
          GuideRow(
            'RQD',
            'Índice de calidad de roca: % de testigo en trozos de más de '
                '10 cm',
          ),
          GuideRow('RMR', 'Clasificación del macizo rocoso de 0 a 100'),
          GuideRow('Sostenimiento', 'Conjunto de elementos que estabilizan'),
          GuideRow(
            'Drenaje ácido de roca',
            'Acidez generada por oxidación de sulfuros expuestos',
          ),
        ],
      ),
    ],
  ),
];
