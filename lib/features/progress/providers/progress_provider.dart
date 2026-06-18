import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_models.dart';
import '../repositories/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final progressOverviewProvider = FutureProvider<ProgressOverviewData>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  return repo.getProgressOverview();
});