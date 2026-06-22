class RekapBidangModel {
  final String bidang;
  final int jumlahAnggota;
  final int target;
  final int terkumpul;

  const RekapBidangModel({
    required this.bidang,
    required this.jumlahAnggota,
    required this.target,
    required this.terkumpul,
  });

  int get sisa => target - terkumpul;
  double get pct => target > 0 ? (terkumpul / target).clamp(0.0, 1.0) : 0.0;
}
