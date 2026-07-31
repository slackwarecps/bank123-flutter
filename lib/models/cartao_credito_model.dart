class CartaoCreditoModel {
  final String bandeira;
  final String final4;
  final double faturaAtual;
  final double limiteDisponivel;

  CartaoCreditoModel({
    required this.bandeira,
    required this.final4,
    required this.faturaAtual,
    required this.limiteDisponivel,
  });

  factory CartaoCreditoModel.fromJson(Map<String, dynamic> json) {
    return CartaoCreditoModel(
      bandeira: json['bandeira'] ?? '',
      final4: json['final'] ?? '0000',
      faturaAtual: (json['faturaAtual'] as num?)?.toDouble() ?? 0.0,
      limiteDisponivel: (json['limiteDisponivel'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get descricao => '$bandeira final $final4';
}
