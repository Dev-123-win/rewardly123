import 'package:rewardly_app/user_service.dart';

class AdRewardService {
  final UserService _userService = UserService();

  Future<void> rewardUserForAd({
    required String uid,
    required int coinsPerAd,
  }) async {
    await _userService.updateCoins(uid, coinsPerAd);
    await _userService.updateAdsWatchedToday(uid);
  }
}
