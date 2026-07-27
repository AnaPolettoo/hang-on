import Foundation

/// Traduz a predição crua do modelo Core ML (`GarmentCategoryClassifier`) numa
/// `ClothingCategory`. `.other` não é classe treinada: é o resultado de o modelo
/// não ter certeza suficiente, mantendo REQ-2.2 (confiança baixa não bloqueia).
enum GarmentLabelMapper {
    /// Ponto de partida medido no test set da Parte A — ajustar se a categoria
    /// cair pra `.other` com frequência em uso real.
    static let confidenceThreshold: Float = 0.5

    static func category(forLabel label: String, confidence: Float) -> ClothingCategory {
        guard confidence >= confidenceThreshold,
              let category = ClothingCategory(rawValue: label),
              category != .other
        else { return .other }
        return category
    }
}
