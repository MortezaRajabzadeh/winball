import 'dart:async';
import 'dart:typed_data';

import 'package:activity_repository/activity_repository.dart';
import 'package:announcement_repository/announcement_repository.dart';
import 'package:base_repository/base_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_repository/file_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:help_repository/help_repository.dart';
import 'package:level_repository/level_repository.dart';
import 'package:site_settings_repository/site_settings_repository.dart';
import 'package:slider_repository/slider_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/models/dialog_model.dart';
import 'package:withdraw_repository/withdraw_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  late final StreamController<DialogModel> dialogStreamController;
  late final FileRepositoryFunctions fileRepositoryFunctions;
  late final ActivityRepositoryFunctions activityRepositoryFunctions;
  late final AnnouncementRepositoryFunctions announcementRepositoryFunctions;
  late final HelpRepositoryFunctions helpRepositoryFunctions;
  late final LevelRepositoryFunctions levelRepositoryFunctions;
  late final SiteSettingRepositoryFunctions siteSettingRepositoryFunctions;
  late final SliderRepositoryFunctions sliderRepositoryFunctions;
  late final WithdrawRepositoryFunctions withdrawRepositoryFunctions;
  late final UserRepositoryFunctions userRepositoryFunctions;
  factory AppBloc() => _shared;
  static final AppBloc _shared = AppBloc._internal();
  AppBloc._internal()
      : super(InitializedAppState(
          currentUser: UserModel.empty,
        )) {
    on<ChangeCurrentUserEvent>(_onChangeCurrentUserEvent);
    on<UploadImageEvent>(_onUploadImageEvent);
    on<CreateActivityEvent>(_onCreateActivityEvent);
    on<EditActivityEvent>(_onEditActivityEvent);
    on<RemoveActivityModelEvent>(_onRemoveActivityModelEvent);
    on<CreateAnnouncementModelEvent>(_onCreateAnnouncementModelEvent);
    on<EditAnnouncementModelEvent>(_onEditAnnouncementModelEvent);
    on<RemoveAnnouncementModelEvent>(_onRemoveAnnouncementModelEvent);
    on<CreateHelpModelEvent>(_onCreateHelpModelEvent);
    on<EditHelpModelEvent>(_onEditHelpModelEvent);
    on<RemoveHelpModelEvent>(_onRemoveHelpModelEvent);
    on<CreateLevelModelEvent>(_onCreateLevelModelEvent);
    on<EditLevelModelEvent>(_onEditLevelModelEvent);
    on<RemoveLevelModelEvent>(_onRemoveLevelModelEvent);
    on<CreateEditSettingModelEvent>(_onCreateEditSettingModelEvent);
    on<RemoveSliderEvent>(_onRemoveSliderEvent);
    on<CreateSliderEvent>(_onCreateSliderEvent);
    on<RejectWithdrawEvent>(_onRejectWithdrawEvent);
    on<PaidWithdrawEvent>(_onPaidWithdrawEvent);
    on<ChangeUserTypeEvent>(_onChangeUserTypeEvent);
    on<ChangeIsDemoAccountEvent>(_onChangeIsDemoAccountEvent);
    on<ChangeUserInventoryEvent>(_onChangeUserInventoryEvent);
    dialogStreamController = StreamController.broadcast();
    fileRepositoryFunctions = const FileRepositoryFunctions();
    activityRepositoryFunctions = const ActivityRepositoryFunctions();
    announcementRepositoryFunctions = const AnnouncementRepositoryFunctions();
    helpRepositoryFunctions = const HelpRepositoryFunctions();
    levelRepositoryFunctions = const LevelRepositoryFunctions();
    siteSettingRepositoryFunctions = const SiteSettingRepositoryFunctions();
    sliderRepositoryFunctions = const SliderRepositoryFunctions();
    withdrawRepositoryFunctions = const WithdrawRepositoryFunctions();
    userRepositoryFunctions = const UserRepositoryFunctions();
  }
  void _onChangeCurrentUserEvent(
      ChangeCurrentUserEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(currentUser: event.userModel));
  }

  Future<void> _onChangeUserInventoryEvent(
      ChangeUserInventoryEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      bool result = await userRepositoryFunctions.changeUserTonAmount(
        userId: event.userId,
        token: state.currentUser.token ?? '',
        tonAmount: event.tonInventory * AppConfigs.tonBaseFactory,
      );
      if (result) {
        result = await userRepositoryFunctions.changeUserStarsAmount(
          amount: event.starsInventory,
          userId: event.userId,
          token: state.currentUser.token ?? '',
        );
        closeDialog();
        if (result) {
          showErrorDialog(
            description: AppTexts.operationSuccess,
            title: AppTexts.message,
          );
        } else {
          addError(AppTexts.anErrorOccurred);
        }
      } else {
        addError(AppTexts.anErrorOccurred);
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onChangeIsDemoAccountEvent(
      ChangeIsDemoAccountEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final bool result = await userRepositoryFunctions.changeUserDemoAccount(
        userId: event.userId,
        isDemo: event.isDemoAccount.convertBooleanToInteger,
        token: state.currentUser.token ?? '',
      );
      closeDialog();
      if (result) {
        showErrorDialog(
          description: AppTexts.operationSuccess,
          title: AppTexts.message,
        );
      } else {
        showErrorDialog(description: AppTexts.anErrorOccurred);
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onChangeUserTypeEvent(
      ChangeUserTypeEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final bool result = await userRepositoryFunctions.changeUserType(
        userType: event.userType.name,
        userId: event.userId,
        token: state.currentUser.token ?? '',
      );
      closeDialog();
      if (result) {
        showErrorDialog(
          description: AppTexts.operationSuccess,
          title: AppTexts.message,
        );
      } else {
        showErrorDialog(description: AppTexts.anErrorOccurred);
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onRejectWithdrawEvent(
      RejectWithdrawEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      withdrawRepositoryFunctions.changeWithdrawStatus(
        withdrawId: event.withdrawId,
        status: WithdrawStatus.faild,
        token: state.currentUser.token ?? '',
      );
      event.removeWithdrawFromList(
        withdrawId: event.withdrawId,
      );
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onPaidWithdrawEvent(
      PaidWithdrawEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      withdrawRepositoryFunctions.changeWithdrawStatus(
        withdrawId: event.withdrawId,
        status: WithdrawStatus.success,
        token: state.currentUser.token ?? '',
      );
      event.removeWithdrawFromList(
        withdrawId: event.withdrawId,
      );
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onCreateSliderEvent(
      CreateSliderEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final SliderModel sliderModel =
          await sliderRepositoryFunctions.createSlider(
        imagePath: event.imagePath,
        token: state.currentUser.token ?? '',
      );
      event.afterSliderCreated(sliderModel: sliderModel);
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onRemoveSliderEvent(
      RemoveSliderEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final bool result = await sliderRepositoryFunctions.deleteSlider(
        sliderId: event.sliderId,
        token: state.currentUser.token ?? '',
      );
      closeDialog();
      if (result) {
        event.afterSliderRemoved(
          sliderId: event.sliderId,
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onCreateEditSettingModelEvent(
      CreateEditSettingModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final SiteSettingModel siteSettingModel =
          await siteSettingRepositoryFunctions.createSiteSetting(
        loadingPicture: event.loadingPicture,
        minWithdrawAmount: event.minWithdrawAmount,
        minDepositAmount: event.minDepositAmount,
        referalPercent: event.referalPercent.convertToNum.toInt(),
        token: state.currentUser.token ?? '',
      );
      event.afterSiteSettingModelCreated(siteSettingModel: siteSettingModel);
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onCreateLevelModelEvent(
      CreateLevelModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final LevelModel levelModel = await levelRepositoryFunctions.createLevel(
        expToUpgrade: event.expToUpgrade,
        levelTag: event.title,
        token: state.currentUser.token ?? '',
      );
      event.afterLevelModelCreated(
        levelModel: levelModel,
      );
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onEditLevelModelEvent(
      EditLevelModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final LevelModel levelModel = await levelRepositoryFunctions.editLevel(
        expToUpgrade: event.expToUpgrade,
        levelTag: event.title,
        levelId: event.levelId,
        token: state.currentUser.token ?? '',
      );

      event.afterLevelModelEdited(levelModel: levelModel);
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onRemoveLevelModelEvent(
      RemoveLevelModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final bool result = await levelRepositoryFunctions.deleteLevelById(
        levelId: event.levelId,
        token: state.currentUser.token ?? '',
      );
      if (result) {
        event.afterLevelModelRemoved(
          levelId: event.levelId,
        );
      }
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onCreateHelpModelEvent(
      CreateHelpModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final HelpModel helpModel = await helpRepositoryFunctions.createHelp(
        description: event.details,
        subsection: event.subsection,
        title: event.title,
        token: state.currentUser.token ?? '',
      );
      event.afterHelpModelCreated(helpModel: helpModel);
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onEditHelpModelEvent(
      EditHelpModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final HelpModel helpModel = await helpRepositoryFunctions.editHelp(
        description: event.details,
        helpId: event.helpId,
        subsection: event.subsection,
        title: event.title,
        token: state.currentUser.token ?? '',
      );
      event.afterHelpModelEdited(helpModel: helpModel);
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onRemoveHelpModelEvent(
      RemoveHelpModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final bool result = await helpRepositoryFunctions.deleteHelpWithId(
        helpId: event.helpId,
        token: state.currentUser.token ?? '',
      );
      if (result) {
        event.afterHelpModelRemoved(
          helpId: event.helpId,
        );
      }
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onRemoveAnnouncementModelEvent(
      RemoveAnnouncementModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final bool result =
          await announcementRepositoryFunctions.deleteAnnouncementById(
        announceId: event.announcementId,
        token: state.currentUser.token ?? '',
      );
      if (result) {
        event.afterAnnouncementRemoved(
          announcementId: event.announcementId,
        );
      }
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onEditAnnouncementModelEvent(
      EditAnnouncementModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final AnnouncementModel announcementModel =
          await announcementRepositoryFunctions.editAnnouncementt(
        announcementId: event.announcementId,
        details: event.details,
        title: event.title,
        token: state.currentUser.token ?? '',
      );
      event.afterAnnouncementModelEdited(announcementModel: announcementModel);
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onCreateAnnouncementModelEvent(
      CreateAnnouncementModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final AnnouncementModel announcementModel =
          await announcementRepositoryFunctions.createAnnouncement(
        title: event.title,
        details: event.details,
        token: state.currentUser.token ?? '',
      );
      closeDialog();
      event.afterAnnouncementCreated(announcementModel: announcementModel);
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onRemoveActivityModelEvent(
      RemoveActivityModelEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final bool result = await activityRepositoryFunctions.deleteActivityById(
        activityId: event.activityId,
        token: state.currentUser.token ?? '',
      );
      if (result) {
        event.afterActivityDeleted(
          activityId: event.activityId,
        );
      }
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onEditActivityEvent(
      EditActivityEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final ActivityModel activityModel =
          await activityRepositoryFunctions.editActivity(
        activityId: event.activityId,
        bannerUrl: event.bannerUrl,
        details: event.details,
        title: event.title,
        token: state.currentUser.token ?? '',
      );
      event.afterActivityEdited(
        activityModel: activityModel,
      );
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onCreateActivityEvent(
      CreateActivityEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final ActivityModel activityModel =
          await activityRepositoryFunctions.createActivity(
        title: event.title,
        bannerUrl: event.bannerUrl,
        details: event.details,
        token: state.currentUser.token ?? '',
      );
      event.afterActivityCreated(activityModel: activityModel);
      closeDialog();
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onUploadImageEvent(
      UploadImageEvent event, Emitter<AppState> emit) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );
      if (result != null) {
        if (kIsWeb) {
          showLoadingDialog();
          final Uint8List bytes = result.files.first.bytes!;
          final String path = await fileRepositoryFunctions.uploadFile(
            fileType: 'image',
            bytes: bytes,
            fileExtension: result.files.first.extension ?? '.jpg',
            token: state.currentUser.token ?? '',
          );
          event.afterFileUploaded(path: path);
          closeDialog();
        }
      }
    } catch (e) {
      addError(e);
    }
  }

  void showLoadingDialog() {
    dialogStreamController.sink.add(
      const DialogModel.loading(),
    );
  }

  void showErrorDialog({
    required String description,
    String title = AppTexts.error,
  }) {
    dialogStreamController.sink.add(
      DialogModel.error(
        description: description,
        title: title,
      ),
    );
  }

  void closeDialog() {
    dialogStreamController.sink.add(
      const DialogModel.closed(),
    );
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    closeDialog();
    if (error is BaseExceptions) {
      showErrorDialog(description: error.error);
    } else {
      showErrorDialog(description: error.toString());
    }
    super.addError(error, stackTrace);
  }

  @override
  Future<void> close() {
    dialogStreamController.close();
    return super.close();
  }
}
