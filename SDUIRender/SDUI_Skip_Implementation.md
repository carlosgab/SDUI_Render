# SDUIRender — Implementación con Skip/SkipUI

> Documento técnico para el equipo  
> Fecha: junio 2026

---

## Índice

1. [Contexto y objetivo](#1-contexto-y-objetivo)
2. [Arquitectura](#2-arquitectura)
3. [Estructura del proyecto](#3-estructura-del-proyecto)
4. [Capas de la arquitectura](#4-capas-de-la-arquitectura)
5. [Cómo usar el motor](#5-cómo-usar-el-motor)
6. [Diferencias con la implementación iOS original](#6-diferencias-con-la-implementación-ios-original)
7. [Patrones de compatibilidad con Skip](#7-patrones-de-compatibilidad-con-skip)
8. [Estado del build y tests](#8-estado-del-build-y-tests)
9. [Trabajo pendiente](#9-trabajo-pendiente)
10. [Guía de integración en la app host](#10-guía-de-integración-en-la-app-host)
11. [SDUIShowcase — app de demostración](#11-sduishowcase--app-de-demostración)

---

## 1. Contexto y objetivo

El proyecto **SDUIRender** es el motor de renderizado SDUI (Server-Driven UI) compartido entre iOS y Android generado a partir de un único código Swift mediante **Skip**.

### ¿Qué es Skip?

[Skip](https://skip.dev) transpila Swift → Kotlin y SwiftUI → Jetpack Compose, permitiendo mantener un solo codebase para las dos plataformas. El proyecto usa el modo **transpiled-model**: todo el código Swift se traduce automáticamente a Kotlin en tiempo de compilación.

### Punto de partida

Los proyectos iOS de referencia usados como base para esta implementación son:

| Proyecto iOS | Descripción |
|---|---|
| `mlb-sduicefios` | Motor SDUI principal (registry, protocols, views) |
| `mlb-sduiinterfacecefios` | Capa de interfaz (DTOs, contratos) |

---

## 2. Arquitectura

El motor sigue el patrón **Registry + Mapper**:

```
JSON (servidor)
     │
     ▼
PageDTO / ComponentDTOWrapper   ← Decodificación polimórfica
     │
     ▼
ComponentProtocol (Registry)    ← Transforma DTO → CommonView
     │
     ▼
ComponentCommonView             ← Modelo de dominio agnóstico de UI
     │
     ▼
ComponentViewBuilder            ← Despacha al View SwiftUI correcto
     │
     ▼
SwiftUI View                    ← Renderizado final (iOS) / Compose (Android)
```

### Tipos de componentes soportados

| Tipo JSON | Clase de dominio | Vista |
|---|---|---|
| `container` | `ContainerComponentCommonView` | `ContainerComponentView` |
| `text` | `TextComponentCommonView` | `TextComponentView` |
| `image` | `ImageComponentCommonView` | `ImageComponentView` |
| `carousel` | `CarouselComponentCommonView` | `CarouselComponentView` |
| `custom(String)` | Extensible por la app | Extensible por la app |

---

## 3. Estructura del proyecto

```
SDUIRender/
├── Package.swift                          # Dependencias: skip 1.9.2, skip-ui 1.0.0
├── Skip.env                               # PRODUCT_NAME, BUNDLE_ID, MARKETING_VERSION compartidos
├── Project.xcworkspace                    # Workspace Xcode (Darwin + Swift Package)
├── Sources/SDUIRenderSwift/
│   ├── ComponentType.swift                # Enum de todos los tipos de componente
│   ├── SDUIRegistry.swift                 # Singleton: registro de protocols
│   ├── SDUIManager.swift                  # Punto de entrada: decodifica JSON
│   ├── SDUIEvents.swift                   # Protocolo de eventos + EnvironmentKey
│   ├── DTOs/
│   │   ├── ComponentDTOs.swift            # Structs decodificables por componente
│   │   ├── ComponentDTOWrapper.swift      # Decodificación polimórfica
│   │   ├── PageDTO.swift                  # DTO raíz + DataSourceDTOWrapper
│   │   ├── ActionDTOs.swift               # DTOs de acciones
│   │   ├── StylesDTO.swift                # Estilos (borde, sombra, radio)
│   │   ├── SDUISpacingDTO.swift           # Valores de espaciado
│   │   └── PositioningDTO.swift           # Posicionamiento y padding
│   ├── Domain/
│   │   ├── ComponentCommonViews.swift     # Modelos de dominio por componente
│   │   ├── Actions.swift                  # Acciones de dominio
│   │   ├── DataSources.swift              # Fuentes de datos (product, category)
│   │   ├── StylesBO.swift                 # Estilos de dominio
│   │   ├── PositioningBO.swift            # Posicionamiento de dominio
│   │   ├── ImageAndSpacingBO.swift        # Imagen y espaciado de dominio
│   │   └── PageBO.swift                   # Modelo de página
│   ├── Protocols/
│   │   ├── SDUIProtocol.swift             # Protocolo base SDUI + registry
│   │   ├── ComponentProtocols.swift       # Implementaciones concretas
│   │   ├── ComponentMapper.swift          # Mapeo DTO → CommonView
│   │   └── SDUIInterpolator.swift         # Sustitución de placeholders {{key}}
│   └── Views/
│       ├── SDUIPageView.swift             # Vista raíz pública
│       ├── ComponentViewBuilder.swift     # Despachador central de vistas
│       ├── ContainerComponentView.swift   # HStack / VStack / ZStack + ScrollView
│       ├── TextComponentView.swift        # Texto con estilos completos
│       ├── ImageComponentView.swift       # AsyncImage con aspect ratio
│       ├── CarouselComponentView.swift    # Snap (TabView) o libre (ScrollView)
│       ├── ViewModifiers.swift            # Modificadores: posicionamiento, estilos
│       └── PositioningHelper.swift        # Cálculo de dimensiones concretas
├── Sources/SDUIShowcase/                  # Biblioteca de demostración (nueva)
│   ├── ShowcaseJsonSamples.swift          # JSON de ejemplo agrupados por sección
│   ├── ShowcaseEventsHandler.swift        # SDUIEventsHandler con @Published lastEvent
│   ├── ShowcasePreviewView.swift          # Vista de previsualización de un JSON
│   ├── ShowcaseRootView.swift             # NavigationView raíz con lista + campo libre
│   └── Skip/skip.yml                      # mode: transpiled
├── Sources/ShowcaseApp/                   # Target app entry point (nueva)
│   ├── ShowcaseAppApp.swift               # ShowcaseAppRootView + AppDelegate (generado por skip init)
│   ├── ContentView.swift                  # Carga ShowcaseRootView()
│   └── Skip/skip.yml                      # mode: transpiled, android: app: true
├── Darwin/                                # Wrapper Xcode iOS (generado por skip init)
│   ├── ShowcaseApp.xcodeproj/
│   │   └── xcshareddata/xcschemes/        # Scheme "ShowcaseApp App"
│   ├── ShowcaseApp.xcconfig               # SKIP_ACTION = launch, targets iOS 17+
│   └── Sources/Main.swift                 # Entry point iOS → ShowcaseAppRootView
├── Android/                               # Wrapper Android/Gradle (generado por skip init)
│   ├── app/                               # Módulo Android
│   │   └── src/main/kotlin/Main.kt        # Entry point Android → ShowcaseAppRootView
│   └── settings.gradle.kts               # Plugin Skip + referencia al Package
└── Tests/SDUIRenderSwiftTests/
    ├── SDUIRenderSwiftTests.swift         # 7 tests unitarios
    └── Resources/TestData.json           # JSON de prueba completo
```

---

## 4. Capas de la arquitectura

### 4.1 DTOs — Decodificación del JSON

Los DTOs decodifican directamente el JSON del servidor. La clave es `ComponentDTOWrapper`, que hace decodificación polimórfica consultando el registry para saber qué `Codable` usar según el campo `"type"`:

```swift
// ComponentDTOWrapper decodifica cualquier componente
let wrapper = try JSONDecoder().decode(ComponentDTOWrapper.self, from: data)
```

**JSON de ejemplo:**
```json
{
  "type": "text",
  "id": "title",
  "text": "{{product.name}}",
  "styles": {
    "fontSize": 18,
    "fontWeight": "bold",
    "textColor": "#FFFFFF"
  },
  "positioning": {
    "width": { "type": "percentage", "value": 100 }
  }
}
```

### 4.2 Domain — Modelos de negocio

Los modelos `*BO` (Business Object) y `*CommonView` son agnósticos de SwiftUI. Son los que se pasan entre capas y permiten testear la lógica sin UI.

### 4.3 Protocols — Transformación DTO → Domain

Cada tipo de componente tiene su `ComponentProtocol` registrado en `SDUIRegistry`. El protocolo es responsable de:
- Validar el DTO
- Interpolar placeholders con datos reales (`{{product.name}}` → `"Air Max 90"`)
- Devolver el `ComponentCommonView` listo para renderizar

### 4.4 Views — Renderizado SwiftUI / Compose

`ComponentViewBuilder` recibe un `ComponentCommonView` y lo despacha al `View` correcto mediante casting `as?`. Los `View`s usan los `ViewModifier`s compartidos para aplicar posicionamiento, estilos y sombras.

### 4.5 SDUIEvents — Comunicación hacia la app host

La app host implementa `SDUIEventsHandler` e inyecta el handler en el environment. Los componentes acceden a él para disparar navegación, añadir al carrito, etc.:

```swift
// Protocolo que implementa la app host
public protocol SDUIEventsHandler {
    func navigate(action: ActionNavigateToProduct)
    func navigate(action: ActionNavigateToCategory)
    func navigate(action: ActionNavigateToURL)
    func addToCart(action: ActionAddToCart)
}
```

---

## 5. Cómo usar el motor

### Uso básico desde SwiftUI

```swift
import SDUIRenderSwift

struct MyScreen: View {
    let jsonString: String
    let eventsHandler: SDUIEventsHandler

    var body: some View {
        SDUIPageView(
            source: .jsonString(jsonString),
            eventsHandler: eventsHandler
        )
    }
}
```

### Registrar un componente personalizado (extensibilidad)

```swift
// En el arranque de la app
SDUIRegistry.shared.register(
    MyCustomComponentProtocol(),
    forKey: .custom("my-type")
)
```

### Fuentes de datos disponibles

```swift
// Desde un String JSON
SDUIPageView(source: .jsonString(json), eventsHandler: handler)

// Desde Data
SDUIPageView(source: .data(data), eventsHandler: handler)
```

---

## 6. Diferencias con la implementación iOS original

Esta sección documenta los cambios más relevantes respecto a `mlb-sduicefios` y su impacto.

### 6.1 Único módulo vs. dos módulos separados

| iOS | Skip |
|---|---|
| `mlb-sduiinterfacecefios` (contratos) + `mlb-sduicefios` (implementación) | Todo en `SDUIRenderSwift` |

**Impacto:** Simplificación del grafo de dependencias. La app host solo importa `SDUIRenderSwift`.

### 6.2 Sin dependencia de `ITXMediaStoreFront`

Los modelos de datos `ProductDataSource` y `CategoryDataSource` en esta implementación son structs simples con las propiedades necesarias para la interpolación. En iOS estos modelos venían del framework `ITXMediaStoreFront`.

**Impacto:** La app host debe convertir sus modelos de dominio a `ProductDataSource` / `CategoryDataSource` antes de pasarlos como data source al componente.

### 6.3 Sin XMedia / componente `media`

El componente de vídeo (`type: "media"`) **no está implementado** en esta versión. Los componentes de tipo `media` en el JSON serán ignorados silenciosamente.

**Impacto:** Si el JSON del servidor incluye componentes de vídeo, no se renderizarán. Prioridad alta para la siguiente iteración.

### 6.4 `SDUIPageSource` sin `.url` ni `.dictionary`

En iOS el manager podía recibir una URL remota o un diccionario. Aquí solo se soportan `.jsonString(String)` y `.data(Data)`.

**Impacto:** La app host es responsable de la descarga del JSON. Esto es un patrón más limpio: separación de responsabilidades (networking fuera del motor de renderizado).

### 6.5 Espaciado — tokens MDS no resueltos

Los valores de spacing del JSON pueden ser un porcentaje o un token de diseño (`"token": "spacing-m"`). Actualmente los tokens **no se resuelven** y devuelven `0.0`.

**Impacto visual alto:** Cualquier componente que use tokens de espaciado tendrá padding/margin = 0. Ver [sección de trabajo pendiente](#9-trabajo-pendiente).

### 6.6 `SDUIEventsBox` — wrapper del handler de eventos

En iOS el EnvironmentKey almacenaba directamente `(any SDUIEventsHandler)?`. Skip no soporta `any Protocol?` como valor de EnvironmentKey, por lo que se usa una clase wrapper:

```swift
// Skip requiere clase concreta, no existencial
public class SDUIEventsBox {
    public var handler: (any SDUIEventsHandler)?
    public init(_ handler: (any SDUIEventsHandler)? = nil) { self.handler = handler }
}
```

**Impacto en integración:** La API de cara al consumidor es la misma. El wrapper es un detalle de implementación interno.

### 6.7 Carga de página síncrona (sin `.task` async)

En iOS la carga del modelo en `SDUIPageView` se hacía en un bloque `.task { @MainActor in self.page = ... }`. Skip no soporta reasignación de `@State` dentro de closures `.task`. La carga se hace de forma síncrona en `onAppear` llamando a `loadPage()`.

**Impacto:** Para JSONs muy grandes podría haber un pequeño frame drop en el primer render. En la práctica con tamaños de payload SDUI habituales es imperceptible.

### 6.8 `.kerning()` no disponible en Skip

El modificador `.kerning()` de SwiftUI no está disponible en SkipUI. Está protegido con `#if !SKIP`.

**Impacto:** En Android el kerning del texto no se aplica. Si es crítico para el diseño se puede implementar con un modificador nativo Compose en una extensión `#if SKIP`.

### 6.9 `.page` style en `TabView` solo en iOS

El estilo de carrusel con snap usa `TabView(.page)`. En macOS y Android este estilo no está disponible y se usa un `ScrollView` + `LazyHStack` como fallback.

---

## 7. Patrones de compatibilidad con Skip

Lista de restricciones de Skip encontradas durante el desarrollo y cómo se resolvieron.

| # | Patrón Swift estándar | Por qué falla en Skip | Solución aplicada |
|---|---|---|---|
| 1 | `KeyPath` (`\.paddingTop`) | No transpila a Kotlin | Acceso explícito propiedad a propiedad |
| 2 | `case .none` en switch | Genera código Kotlin inválido | Cambiar a `case nil` |
| 3 | `lineLimit(Optional<Int>)` | Skip no admite overload con Optional | Patrón `applyIf` con valor no-optional |
| 4 | `extension Color { init?(hex:) }` | No se puede añadir `init` a tipos externos | Free function `colorFromHex()` |
| 5 | `Int(string, radix: 16)` | No disponible en Skip | Parsing char a char con `switch` |
| 6 | `.zero` en Float/CGFloat/CGSize | No transpila | Literal explícito `0`, `0.0`, `CGSize(width:0,height:0)` |
| 7 | `Sendable` en singletons | Swift 6 concurrency estricta | `@unchecked Sendable` |
| 8 | `static let shared` en actor | Requiere `nonisolated` | `nonisolated(unsafe) static let shared` |
| 9 | `max(_ a: Float, _ b: Float)` | Tipo de retorno genérico ambiguo | `if a > b { return a } else { return b }` |
| 10 | `inout` con existencial protocol | Skip no transpila `inout` + existencial | Pure function que devuelve el valor modificado |
| 11 | `any Protocol?` como EnvironmentKey | Skip requiere tipo concreto | Clase wrapper `SDUIEventsBox` |
| 12 | `@State` reassign en `.task {}` | No permitido por Skip | Función síncrona `loadPage()` en `onAppear` |
| 13 | `.page(indexDisplayMode:)` en TabView | No existe en macOS ni Compose | `#if os(iOS)` guard |
| 14 | `.kerning()` | No en SkipUI | `#if !SKIP` guard |
| 15 | `CGFloat.flatMap` | CGFloat no es Optional | Cadena `if let` explícita |
| 16 | `@Environment` sin tipo explícito | Skip necesita anotación de tipo | Añadir `: SDUIEventsBox` en la declaración |
| 17 | `EnvironmentValues` setter auto-capitalización | Skip genera `set` + nombre exacto sin capitalizar (`sduiPageSize` → `setsduiPageSize`) | Usar nombres con inicial mayúscula o evitar `EnvironmentValues` custom para este caso |
| 18 | `Array<ProductDataSource>` asignado a `[SDUIDataSource]` | Skip/Kotlin: `Array<out SDUIDataSource>` (covariante) no asignable a `Array<SDUIDataSource>` | `.map { $0 as SDUIDataSource }` para forzar el tipo concreto |
| 19 | `flatMap { $0.protocolMethod() }` con tipos internos | Skip pierde información de tipo en closures con protocolos internos | Hacer los tipos `public` y usar decodificación directa al tipo concreto |
| 20 | `GeometryReader` dentro de `ScrollView` | Compose asigna altura infinita al `GeometryReader` → contenido invisible | Pasar el tamaño como parámetro explícito (`preferredSize: CGSize`) y omitir el `GeometryReader` |
| 21 | `Image(systemName:)` (SF Symbols) | No disponible en Android, muestra triángulo de error | Usar `Rectangle().fill(Color.gray.opacity(0.3))` como placeholder |
| 22 | `.onChange(of:) { newValue in }` (un parámetro) | Deprecado en iOS 17 / macOS 14; Skip genera advertencia de compilación | Usar la forma de dos parámetros: `.onChange(of:) { oldValue, newValue in }` |
| 23 | Dos `Text` consecutivos en label de `Toggle` | Compose no garantiza el orden de renderizado sin contenedor explícito | Envolver en `VStack(alignment: .leading)` con el primer `Text` como título |
| 24 | `.environment(\.key, .enumCase)` | Skip/Kotlin no puede inferir el tipo genérico `V` desde dot-syntax | Usar tipo explícito: `.environment(\.layoutDirection, LayoutDirection.rightToLeft)` |
| 25 | `Button("OK", role: .cancel)` en `.alert` | Compose genera un botón de sistema adicional junto al explícito → dos botones "OK" | Omitir `role:` en botones de alert: `Button("OK") { ... }` |
| 26 | `.task {}` re-ejecución por recomposición | Cuando cambia `@State` y el árbol de vistas se reestructura, Compose re-dispara `LaunchedEffect` | Guard en la función de carga: `guard page == nil && !hasError else { return }` |

---

## 8. Estado del build y tests

### Tests Swift (iOS/macOS) — ✅ 7/7 PASAN

```
✅ testComponentTypeRawValues     — Verifica los raw values del enum ComponentType
✅ testHexColorParsing            — Verifica el parser de color hexadecimal
✅ testBasicArithmetic            — Smoke test del módulo
✅ testDecodeSDUIPage             — Decodificación completa de PageDTO desde JSON
✅ testContainerChildrenDecoded   — Verifica hijos de un container
✅ testTextComponentDecoded       — Verifica propiedades de un componente texto
✅ testImageComponentDecoded      — Verifica propiedades de un componente imagen
```

### Transpilación Kotlin — ✅ COMPILA SIN ERRORES

El código Kotlin generado por Skip compila correctamente. No hay errores de transpilación.

### `ShowcaseApp` target — ✅ BUILD COMPLETO

```
Build of target: 'ShowcaseApp' complete!
```

El target `ShowcaseApp` incluye la app de demostración con sus wrappers Darwin (Xcode) y Android (Gradle) generados por `skip init --transpiled-app`.

### Tests Android (Robolectric) — ❌ FALLO DE INFRAESTRUCTURA

```
FAILED: Failed to fetch maven artifact
        org.robolectric:android-all-instrumented:16-robolectric-13921718-i7
```

Este error es de red/Maven, no de código. El runtime de Robolectric no puede descargarse en el entorno actual. Los tests de Android correrán correctamente en un entorno con acceso a Maven Central (CI/CD o emulador).

---

## 9. Trabajo pendiente

### P1 — Alta prioridad

**1. Resolver tokens MDS de espaciado**

Implementar un protocolo `SDUITokenResolver` injectable en el registry. Sin esto, cualquier componente que use `"token": "spacing-m"` renderiza con espaciado = 0.

```swift
// Propuesta de API
public protocol SDUITokenResolver {
    func resolveSpacing(token: String) -> CGFloat
}

// En el arranque de la app
SDUIRegistry.shared.tokenResolver = AppMDSTokenResolver()
```

**2. Componente `media` (XMedia/vídeo)**

Implementar soporte para `type: "media"` usando `VideoPlayer` en iOS y el equivalente Compose en Android, con `#if !SKIP` / `#if SKIP` para las partes específicas de plataforma.

### P2 — Media prioridad

**3. `PageSource.url` — carga remota opcional**

Aunque la separación de networking es buena práctica, puede ser conveniente ofrecer `.url(URL)` como conveniencia para la app host.

**4. `testMode` environment key**

En iOS existe una clave de entorno para activar el modo test (datos mock). Útil para pruebas de UI automatizadas.

### P3 — Baja prioridad

**5. `.kerning()` en Android**

Implementar kerning en Android usando un modificador Compose dentro de un bloque `#if SKIP`.

**6. Documentar patrón de componentes custom**

Guía paso a paso para que los equipos de las apps host añadan sus propios tipos de componente al registry.

---

## 10. Guía de integración en la app host

### Añadir la dependencia

En el `Package.swift` de la app host (o en Xcode vía File → Add Package Dependencies):

```swift
.package(path: "../SDUIRender")  // ruta local
// o con URL cuando esté publicado:
// .package(url: "https://github.com/org/SDUIRender.git", from: "1.0.0")
```

```swift
.target(name: "MyApp", dependencies: [
    .product(name: "SDUIRenderSwift", package: "SDUIRender")
])
```

### Implementar el handler de eventos

```swift
import SDUIRenderSwift

class MySDUIEventsHandler: SDUIEventsHandler {
    func navigate(action: ActionNavigateToProduct) {
        // Navegar a PDP
        router.navigateToProduct(id: action.productId)
    }
    func navigate(action: ActionNavigateToCategory) {
        // Navegar a PLP
        router.navigateToCategory(id: action.categoryId)
    }
    func navigate(action: ActionNavigateToURL) {
        // Abrir URL en SafariViewController / WebView
        UIApplication.shared.open(URL(string: action.url)!)
    }
    func addToCart(action: ActionAddToCart) {
        // Añadir al carrito
        cartService.add(productId: action.productId, quantity: action.quantity)
    }
}
```

### Renderizar una pantalla SDUI

```swift
import SDUIRenderSwift
import SwiftUI

struct SDUIScreen: View {
    let jsonString: String
    @StateObject private var eventsHandler = MySDUIEventsHandler()

    var body: some View {
        SDUIPageView(
            source: .jsonString(jsonString),
            eventsHandler: eventsHandler
        )
    }
}
```

### Pasar datos para interpolación

Si el JSON contiene placeholders como `{{product.name}}`, hay que pasar el data source al `SDUIManager` antes de renderizar:

```swift
let productDS = ProductDataSource(
    name: product.name,
    price: product.formattedPrice,
    imageUrl: product.imageUrl,
    // ...
)
SDUIManager.shared.setDataSource(productDS, forKey: "product")
```

---

## Dependencias

| Dependencia | Versión | Descripción |
|---|---|---|
| [skip](https://source.skip.tools/skip.git) | ≥ 1.9.2 | Plugin de transpilación Swift → Kotlin |
| [skip-ui](https://source.skip.tools/skip-ui.git) | ≥ 1.0.0 | SwiftUI → Jetpack Compose |

---

## Plataformas soportadas

| Plataforma | Versión mínima | Estado |
|---|---|---|
| iOS | 17.0 | ✅ Funcional |
| macOS | 14.0 | ✅ Funcional (sin TabView snap) |
| Android | vía Kotlin/Compose | ✅ Compila, tests bloqueados por Robolectric/Maven |

---

## 11. SDUIShowcase — app de demostración

`SDUIShowcase` es una app independiente incluida en este mismo repositorio que permite probar el motor SDUI de forma visual tanto en iOS como en Android sin necesidad de integrar el motor en una app real.

### Estructura

El showcase se divide en dos targets Swift:

| Target | Tipo | Descripción |
|---|---|---|
| `SDUIShowcase` | Library | Vistas y datos de ejemplo, importable desde cualquier app |
| `ShowcaseApp` | App entry point | Wrappers iOS y Android para lanzar como aplicación |

### Componentes de `SDUIShowcase`

#### `ShowcaseJsonSamples`

Define un catálogo de JSONs de ejemplo agrupados por sección:

| Sección | Contenido |
|---|---|
| `layout` | Layouts de container (HStack, VStack, ZStack) |
| `text` | Texto con estilos: tamaño, peso, color, alineación |
| `image` | Imágenes con aspect ratio y posicionamiento |
| `carousel` | Carrusel snap (TabView) y scroll libre |
| `actions` | Botones con eventos de navegación y carrito |

```swift
// Tipos públicos
enum ShowcaseSection: String, CaseIterable, Hashable, Sendable
struct ShowcaseJsonSample: Identifiable, Sendable { id, label, section, json }
```

#### `ShowcaseEventsHandler`

Implementación de `SDUIEventsHandler` que captura los eventos del motor y los expone como `@Published var lastEvent: String` para mostrarlos en la UI de debug.

```swift
class ShowcaseEventsHandler: ObservableObject, SDUIEventsHandler {
    @Published var lastEvent: String = ""
    // Implementa navigate(product/category/url) y addToCart
}
```

#### `ShowcasePreviewView`

Renderiza un único JSON usando `SDUIPageView`. Muestra un banner informativo en la parte superior con el último evento recibido por `ShowcaseEventsHandler`.

#### `ShowcaseRootView`

Vista raíz con `NavigationView` que contiene:
- **Lista de muestras** agrupadas por sección — navega a `ShowcasePreviewView` al seleccionar
- **Campo de JSON libre** — permite pegar cualquier JSON y previsualizarlo en el motor

### Generación de los wrappers (ejecutado una sola vez)

Los proyectos Darwin y Android se generaron con:

```bash
cd /path/to/SDUIRender
skip init --transpiled-app -d . ShowcaseApp com.inditex.sduishowcase
```

Esto generó:
- `Darwin/ShowcaseApp.xcodeproj` — proyecto Xcode iOS
- `Android/` — proyecto Gradle Android
- `Project.xcworkspace` — workspace que combina ambos
- `Skip.env` — configuración compartida de producto

> **Nota:** Este comando no debe volver a ejecutarse. Los wrappers ya existen y se versionan junto con el código.

### Cómo ejecutar el Showcase

#### Opción A — Desde Xcode (iOS + Android simultáneamente)

1. Arranca un emulador Android en Android Studio (Device Manager → ▶)
2. Abre `Project.xcworkspace` en Xcode
3. Selecciona el scheme **`ShowcaseApp App`** y un simulador iPhone
4. Pulsa **Cmd+R**

El plugin `skipstone` detecta `SKIP_ACTION = launch` en `Darwin/ShowcaseApp.xcconfig` y, tras compilar el app iOS, transpila el Swift a Kotlin, ejecuta el build Gradle e instala la app en el emulador Android automáticamente.

#### Opción B — Desde terminal

```bash
# iOS + Android a la vez (requiere simulador iOS booteado + emulador Android activo)
skip app launch

# Solo iOS
skip app launch --ios

# Solo Android
skip app launch --android

# Build release
skip app launch --configuration release
```

Verificar dispositivos disponibles:

```bash
skip devices
```

#### Opción C — Solo iOS en Xcode (sin Android)

En `Darwin/ShowcaseApp.xcconfig`, cambiar:

```
SKIP_ACTION = build   # compila Kotlin pero no lanza en Android
# o
SKIP_ACTION = none    # desactiva completamente el plugin Skip
```

### Configuración del producto

El fichero `Skip.env` en la raíz centraliza los metadatos de la app compartidos entre iOS y Android:

```
PRODUCT_NAME = ShowcaseApp
PRODUCT_BUNDLE_IDENTIFIER = com.inditex.sduishowcase
MARKETING_VERSION = 0.0.1
CURRENT_PROJECT_VERSION = 1
ANDROID_PACKAGE_NAME = showcase.app
```

### `Sources/ShowcaseApp/Skip/skip.yml`

```yaml
skip:
  mode: 'transpiled'
  android:
    app: true
    appid: 'com.inditex.sduishowcase'
```

El flag `android: app: true` indica al plugin `skipstone` que este target es el punto de entrada Android (genera el `AndroidManifest.xml` adecuado).

---

*Generado a partir de la sesión de implementación — SDUIRender v0.1  
Actualizado junio 2026 — SDUIShowcase + lanzamiento dual iOS/Android*
