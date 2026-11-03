class AdminOverviewModel {
  const AdminOverviewModel({
    required this.booksCount,
    required this.teachersCount,
    required this.pendingInvitesCount,
  });

  final int booksCount;
  final int teachersCount;
  final int pendingInvitesCount;

  factory AdminOverviewModel.fromJson(Map<String, dynamic> json) => AdminOverviewModel(
    booksCount: json['books_count'] as int,
    teachersCount: json['teachers_count'] as int,
    pendingInvitesCount: json['pending_invites_count'] as int,
  );
}