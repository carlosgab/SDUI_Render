import Foundation

// MARK: - Section

public enum ShowcaseSection: Int, CaseIterable, Identifiable, Comparable, Hashable, Sendable {
    case layout    = 0
    case text      = 1
    case media     = 2
    case actions   = 3
    case carousel  = 4
    case styles    = 5
    case editorial = 6
    case dataSource = 7

    public var id: Int { rawValue }

    public static func < (lhs: ShowcaseSection, rhs: ShowcaseSection) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var label: String {
        switch self {
        case .layout:     "Layout"
        case .text:       "Text"
        case .media:      "Media"
        case .actions:    "Actions"
        case .carousel:   "Carousel"
        case .styles:     "Styles"
        case .editorial:  "Editorials"
        case .dataSource: "DataSource"
        }
    }
}

// MARK: - Sample

public enum ShowcaseJsonSample: String, CaseIterable, Identifiable, Sendable {
    // Layout
    case direction
    case alignment
    case aspectRatio
    case aspectRatio2
    case aspectRatio3
    case spacing
    case relativeSpacing
    case scrollable
    case rotation
    case rotation2
    // Styles
    case styles
    case granularBorders
    case mdsColors
    case fonts
    case darkMode
    // Media
    case storeFrontMedia
    case videoControls
    // Carousel
    case carousel
    case carouselActions
    case carouselBasicCEF1048
    case carouselBehaviourCEF1049
    case carouselBehaviourCEF1049text2
    case carouselBehaviourCEF1049text3
    case carouselBehaviourCEF1049text4
    case carouselDatasource1170
    case carouselImage
    case carouselImageIncreasedHeight
    case carouselImageCarouselHeightDefined
    case carouselImageAutoHeight
    case carouselProducts
    case carouselTextShort
    case carouselTextLong
    case carouselImageAndText
    case carouselVariableWidth
    // Text
    case textFormatMarkDown
    case textFormatFontStyles
    case textFormatSizing
    case textStyles
    case textScaling
    case textAutoScaling
    case textWidthScaling
    case relativeFontSize
    case textAlignmentVerticalContainer
    case textAlignmentHorizontalContainer
    case textAlignmentStackContainer
    // Actions
    case actions1
    case actions2
    // DataSource
    case dataSourceBasic
    case dataSourceIterative
    // Editorial
    case masonryEditorial
    case skyEditorial

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .direction:                         "Direction"
        case .alignment:                         "Alignment"
        case .aspectRatio:                       "Aspect ratio"
        case .aspectRatio2:                      "Aspect ratio 2"
        case .aspectRatio3:                      "Aspect ratio 3"
        case .spacing:                           "Spacing"
        case .relativeSpacing:                   "Relative spacing"
        case .scrollable:                        "Scrollable overflow"
        case .rotation:                          "Rotation"
        case .rotation2:                         "Rotation with container and image"
        case .styles:                            "Styles"
        case .granularBorders:                   "Granular borders"
        case .textFormatMarkDown:                "Text Markdown format"
        case .textFormatFontStyles:              "Text font styles"
        case .textFormatSizing:                  "Text format basics"
        case .textStyles:                        "Text styles"
        case .textScaling:                       "Scaling"
        case .textAutoScaling:                   "Auto scaling"
        case .textWidthScaling:                  "Width scaling"
        case .relativeFontSize:                  "Relative font size"
        case .textAlignmentVerticalContainer:    "Text alignment in vertical container"
        case .textAlignmentHorizontalContainer:  "Text alignment in horizontal container"
        case .textAlignmentStackContainer:       "Text alignment in stack container"
        case .storeFrontMedia:                   "StoreFrontMedia"
        case .videoControls:                     "Video controls"
        case .actions1:                          "Actions 1"
        case .actions2:                          "Actions 2"
        case .carousel:                          "Carousel"
        case .carouselActions:                   "Carousel with actions"
        case .carouselBasicCEF1048:              "Carousel basic"
        case .carouselBehaviourCEF1049:          "Carousel behaviour"
        case .carouselBehaviourCEF1049text2:     "Carousel behaviour with text 2"
        case .carouselBehaviourCEF1049text3:     "Carousel behaviour with text 3"
        case .carouselBehaviourCEF1049text4:     "Carousel behaviour with text 4"
        case .carouselDatasource1170:            "Carousel with DataSource"
        case .carouselImage:                     "Carousel image"
        case .carouselImageIncreasedHeight:      "Carousel image increasing items height"
        case .carouselImageCarouselHeightDefined:"Carousel image with container defined height"
        case .carouselImageAutoHeight:           "Carousel image with auto height"
        case .carouselProducts:                  "Carousel with product summaries"
        case .carouselTextShort:                 "Carousel text with last short text"
        case .carouselTextLong:                  "Carousel text with last long text"
        case .carouselImageAndText:              "Carousel text with image and text"
        case .carouselVariableWidth:             "Carousel variable width"
        case .mdsColors:                         "MDS Colors"
        case .fonts:                             "Fonts"
        case .darkMode:                          "Dark mode texts"
        case .masonryEditorial:                  "Masonry Editorial"
        case .skyEditorial:                      "Sky Editorial"
        case .dataSourceBasic:                   "DataSource Basic"
        case .dataSourceIterative:               "DataSource Iterative"
        }
    }

    public var section: ShowcaseSection {
        switch self {
        case .direction, .alignment, .aspectRatio, .aspectRatio2, .aspectRatio3,
             .spacing, .relativeSpacing, .scrollable, .rotation, .rotation2,
             .styles, .granularBorders:
            return .layout
        case .textFormatMarkDown, .textFormatFontStyles, .textFormatSizing, .textStyles,
             .textScaling, .textAutoScaling, .textWidthScaling, .relativeFontSize,
             .textAlignmentVerticalContainer, .textAlignmentHorizontalContainer, .textAlignmentStackContainer:
            return .text
        case .storeFrontMedia, .videoControls:
            return .media
        case .actions1, .actions2:
            return .actions
        case .carousel, .carouselActions, .carouselBasicCEF1048, .carouselBehaviourCEF1049,
             .carouselBehaviourCEF1049text2, .carouselBehaviourCEF1049text3, .carouselBehaviourCEF1049text4,
             .carouselDatasource1170, .carouselImage, .carouselImageIncreasedHeight,
             .carouselImageCarouselHeightDefined, .carouselImageAutoHeight, .carouselProducts,
             .carouselTextShort, .carouselTextLong, .carouselImageAndText, .carouselVariableWidth:
            return .carousel
        case .mdsColors, .fonts, .darkMode:
            return .styles
        case .masonryEditorial, .skyEditorial:
            return .editorial
        case .dataSourceBasic, .dataSourceIterative:
            return .dataSource
        }
    }

    private var jsonFileName: String {
        switch self {
        case .direction:                         "SDUI_container_direction_CEF-912"
        case .alignment:                         "SDUI_container_alignment_CEF-913"
        case .aspectRatio:                       "SDUI_container_aspect_ratio"
        case .aspectRatio2:                      "SDUI_container_aspect_ratio2"
        case .aspectRatio3:                      "SDUI_container_aspect_ratio3"
        case .spacing:                           "SDUI_container_spacing_CEF-913"
        case .relativeSpacing:                   "SDUI_relative_spacing_CATALOGO-41802"
        case .scrollable:                        "SDUI_container_overflow_CATALOGO-41608"
        case .rotation:                          "SDUI_rotation_CATALOGO-41904"
        case .rotation2:                         "SDUI_rotation_CATALOGO-41904_2"
        case .styles:                            "SDUI_container_styles_CEF-916"
        case .granularBorders:                   "SDUI_container_granular_borders_CATALOGO-41180"
        case .textFormatMarkDown:                "SDUI_text_markdown_CEF-43"
        case .textFormatFontStyles:              "SDUI_text_font_styles_CEF-1341"
        case .textFormatSizing:                  "SDUI_text_font_size_CEF-1341"
        case .textStyles:                        "SDUI_text_styles_CEF-43"
        case .textScaling:                       "SDUI_text_size_scaling_CEF-43"
        case .textAutoScaling:                   "SDUI_text_content_auto_scaling_CEF-43"
        case .textWidthScaling:                  "SDUI_text_content_width_scaling_CEF-1636"
        case .relativeFontSize:                  "SDUI_relative_font_size_CEF-1509"
        case .textAlignmentVerticalContainer:    "SDUI_text_font_align_vertical_container_CEF-XXX"
        case .textAlignmentHorizontalContainer:  "SDUI_text_font_align_horizontal_container_CEF-XXX"
        case .textAlignmentStackContainer:       "SDUI_text_font_align_stack_container_CEF-XXX"
        case .storeFrontMedia:                   "SDUI_storeFrontMedia"
        case .videoControls:                     "SDUI_video_controls"
        case .actions1:                          "SDUI_actions"
        case .actions2:                          "SDUI_basic_actions_CEF-1148"
        case .carousel:                          "SDUI_carousel"
        case .carouselActions:                   "SDUI_carousel_actions_CEF-2904"
        case .carouselBasicCEF1048:              "SDUI_carousel_basic_CEF-1048"
        case .carouselBehaviourCEF1049:          "SDUI_carousel_behaviour_CEF-1049"
        case .carouselBehaviourCEF1049text2:     "SDUI_carousel_behaviour_CEF-1049_2_text"
        case .carouselBehaviourCEF1049text3:     "SDUI_carousel_behaviour_CEF-1049_3_text"
        case .carouselBehaviourCEF1049text4:     "SDUI_carousel_behaviour_CEF-1049_4_text"
        case .carouselDatasource1170:            "SDUI_carousel_datasource-CEF-1170"
        case .carouselImage:                     "SDUI_carousel-image_CEF-1226"
        case .carouselImageIncreasedHeight:      "SDUI_carousel-image_CEF-1226_2"
        case .carouselImageCarouselHeightDefined:"SDUI_carousel-image_CEF-1226_3"
        case .carouselImageAutoHeight:           "SDUI_carousel-image_CEF-1226_4"
        case .carouselProducts:                  "SDUI_carousel_products_MOBECOM-615"
        case .carouselTextShort:                 "SDUI_carousel_text_CEF-1226"
        case .carouselTextLong:                  "SDUI_carousel_text_CEF-1226_2"
        case .carouselImageAndText:              "SDUI_carousel_mixed_CEF-1226"
        case .carouselVariableWidth:             "SDUI_carousel_variable_width_CATALOGO-41822"
        case .mdsColors:                         "SDUI_mds_colors"
        case .fonts:                             "SDUI_text_fonts"
        case .darkMode:                          "SDUI_dark_mode_CATALOGO-43499"
        case .masonryEditorial:                  "SDUI_editorial_masonry"
        case .skyEditorial:                      "SDUI-sky-editorial"
        case .dataSourceBasic:                   "SDUI_basic_dataSource_showcase"
        case .dataSourceIterative:               "SDUI_iterative_dataSource_showcase"
        }
    }

    public var json: String {
        let url = Bundle.module.url(forResource: jsonFileName, withExtension: "json", subdirectory: "JSON")
                ?? Bundle.module.url(forResource: jsonFileName, withExtension: "json")
        guard let url, let content = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        return content
    }

    public static func samples(for section: ShowcaseSection) -> [ShowcaseJsonSample] {
        allCases.filter { $0.section == section }
    }
}
