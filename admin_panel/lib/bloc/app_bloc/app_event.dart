part of 'app_bloc.dart';

abstract class AppEvent {
  const AppEvent();
}

class UploadImageEvent extends AppEvent {
  final void Function({required String path}) afterFileUploaded;
  const UploadImageEvent({
    required this.afterFileUploaded,
  });
}

class ChangeCurrentUserEvent extends AppEvent {
  final UserModel userModel;
  const ChangeCurrentUserEvent({required this.userModel});
}

class CreateActivityEvent extends AppEvent {
  final String title;
  final String details;
  final String bannerUrl;
  final void Function({required ActivityModel activityModel})
      afterActivityCreated;
  const CreateActivityEvent({
    required this.title,
    required this.details,
    required this.bannerUrl,
    required this.afterActivityCreated,
  });
}

class EditActivityEvent extends AppEvent {
  final int activityId;
  final String title;
  final String bannerUrl;
  final String details;
  final void Function({required ActivityModel activityModel})
      afterActivityEdited;
  const EditActivityEvent({
    required this.activityId,
    required this.bannerUrl,
    required this.details,
    required this.title,
    required this.afterActivityEdited,
  });
}

class RemoveActivityModelEvent extends AppEvent {
  final int activityId;
  final void Function({required int activityId}) afterActivityDeleted;
  const RemoveActivityModelEvent({
    required this.activityId,
    required this.afterActivityDeleted,
  });
}

class CreateAnnouncementModelEvent extends AppEvent {
  final String title;
  final String details;
  final void Function({required AnnouncementModel announcementModel})
      afterAnnouncementCreated;
  const CreateAnnouncementModelEvent({
    required this.title,
    required this.details,
    required this.afterAnnouncementCreated,
  });
}

class EditAnnouncementModelEvent extends AppEvent {
  final int announcementId;
  final String title;
  final String details;
  final void Function({required AnnouncementModel announcementModel})
      afterAnnouncementModelEdited;
  const EditAnnouncementModelEvent({
    required this.afterAnnouncementModelEdited,
    required this.announcementId,
    required this.details,
    required this.title,
  });
}

class RemoveAnnouncementModelEvent extends AppEvent {
  final int announcementId;
  final void Function({required int announcementId}) afterAnnouncementRemoved;
  const RemoveAnnouncementModelEvent({
    required this.announcementId,
    required this.afterAnnouncementRemoved,
  });
}

class CreateHelpModelEvent extends AppEvent {
  final String title;
  final String details;
  final String subsection;
  final void Function({required HelpModel helpModel}) afterHelpModelCreated;
  const CreateHelpModelEvent({
    required this.title,
    required this.details,
    required this.subsection,
    required this.afterHelpModelCreated,
  });
}

class EditHelpModelEvent extends AppEvent {
  final int helpId;
  final String title;
  final String details;
  final String subsection;
  final void Function({required HelpModel helpModel}) afterHelpModelEdited;
  const EditHelpModelEvent({
    required this.afterHelpModelEdited,
    required this.helpId,
    required this.details,
    required this.subsection,
    required this.title,
  });
}

class RemoveHelpModelEvent extends AppEvent {
  final int helpId;
  final void Function({required int helpId}) afterHelpModelRemoved;
  const RemoveHelpModelEvent({
    required this.helpId,
    required this.afterHelpModelRemoved,
  });
}

class CreateLevelModelEvent extends AppEvent {
  final String title;
  final String expToUpgrade;
  final void Function({required LevelModel levelModel}) afterLevelModelCreated;
  const CreateLevelModelEvent({
    required this.title,
    required this.expToUpgrade,
    required this.afterLevelModelCreated,
  });
}

class EditLevelModelEvent extends AppEvent {
  final int levelId;
  final String title;
  final String expToUpgrade;
  final void Function({required LevelModel levelModel}) afterLevelModelEdited;
  const EditLevelModelEvent({
    required this.afterLevelModelEdited,
    required this.expToUpgrade,
    required this.levelId,
    required this.title,
  });
}

class RemoveLevelModelEvent extends AppEvent {
  final int levelId;
  final void Function({required int levelId}) afterLevelModelRemoved;
  const RemoveLevelModelEvent({
    required this.afterLevelModelRemoved,
    required this.levelId,
  });
}

class CreateEditSettingModelEvent extends AppEvent {
  final String loadingPicture;
  final String minWithdrawAmount;
  final String minDepositAmount;
  final String referalPercent;
  final void Function({required SiteSettingModel siteSettingModel})
      afterSiteSettingModelCreated;
  const CreateEditSettingModelEvent({
    required this.loadingPicture,
    required this.minDepositAmount,
    required this.minWithdrawAmount,
    required this.referalPercent,
    required this.afterSiteSettingModelCreated,
  });
}

class RemoveSliderEvent extends AppEvent {
  final int sliderId;
  final void Function({required int sliderId}) afterSliderRemoved;
  const RemoveSliderEvent({
    required this.sliderId,
    required this.afterSliderRemoved,
  });
}

class CreateSliderEvent extends AppEvent {
  final String imagePath;
  final void Function({required SliderModel sliderModel}) afterSliderCreated;
  const CreateSliderEvent({
    required this.imagePath,
    required this.afterSliderCreated,
  });
}

class RejectWithdrawEvent extends AppEvent {
  final int withdrawId;
  final void Function({required int withdrawId}) removeWithdrawFromList;
  const RejectWithdrawEvent({
    required this.withdrawId,
    required this.removeWithdrawFromList,
  });
}

class PaidWithdrawEvent extends AppEvent {
  final int withdrawId;
  final void Function({required int withdrawId}) removeWithdrawFromList;
  const PaidWithdrawEvent({
    required this.withdrawId,
    required this.removeWithdrawFromList,
  });
}

class ChangeUserTypeEvent extends AppEvent {
  final UserType userType;
  final int userId;
  const ChangeUserTypeEvent({
    required this.userType,
    required this.userId,
  });
}

class ChangeIsDemoAccountEvent extends AppEvent {
  final int userId;
  final bool isDemoAccount;
  const ChangeIsDemoAccountEvent(
      {required this.userId, required this.isDemoAccount});
}

class ChangeUserInventoryEvent extends AppEvent {
  final int starsInventory;
  final double tonInventory;
  final int userId;
  const ChangeUserInventoryEvent({
    required this.starsInventory,
    required this.tonInventory,
    required this.userId,
  });
}
