import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:site_settings_repository/site_settings_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/global/custom_space_widget.dart';
import 'package:winball_admin_panel/widgets/global/loading_widget.dart';

class SiteSettingScreen extends StatefulWidget {
  const SiteSettingScreen({super.key});

  @override
  State<SiteSettingScreen> createState() => _SiteSettingScreenState();
}

class _SiteSettingScreenState extends State<SiteSettingScreen> {
  late final GlobalKey<FormState> _formKey;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<SiteSettingModel> siteSettingModelValueNotifier;
  late final SiteSettingRepositoryFunctions siteSettingRepositoryFunctions;
  late final TextEditingController minDepositAmountTextEditingController,
      minWithdrawAmountTextEditingController,
      referalPercentTextEditingController;
  Future<void> initializeDatas() async {
    minDepositAmountTextEditingController = TextEditingController();
    minWithdrawAmountTextEditingController = TextEditingController();
    referalPercentTextEditingController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    siteSettingRepositoryFunctions = const SiteSettingRepositoryFunctions();
    final AppBloc appBloc = context.readAppBloc;
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    siteSettingModelValueNotifier =
        ValueNotifier<SiteSettingModel>(SiteSettingModel.empty);
    try {
      final List<SiteSettingModel> settings =
          await siteSettingRepositoryFunctions.getSiteSettings(
        token: appBloc.state.currentUser.token ?? '',
      );
      if (settings.isNotEmpty) {
        changeSiteSettingValueNotifier(
          siteSettingModel: settings.first,
        );
      }
      changeIsLoadingValueNotifier(isLoading: false);
    } catch (e) {
      appBloc.addError(e);
    }
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? isLoadingValueNotifier.value;
  }

  void changeSiteSettingValueNotifier(
      {required SiteSettingModel siteSettingModel}) {
    siteSettingModelValueNotifier.value = siteSettingModel;
    minDepositAmountTextEditingController.text =
        siteSettingModel.minDepositAmount;
    minWithdrawAmountTextEditingController.text =
        siteSettingModel.minWithdrawAmount;
    referalPercentTextEditingController.text =
        siteSettingModel.referalPercent.toString();
  }

  void dispositionalDatas() {
    isLoadingValueNotifier.dispose();
    siteSettingModelValueNotifier.dispose();
    minDepositAmountTextEditingController.dispose();
    minWithdrawAmountTextEditingController.dispose();
    referalPercentTextEditingController.dispose();
  }

  void changeImageOfSettings({required String path}) {
    SiteSettingModel setting = siteSettingModelValueNotifier.value;
    setting = setting.copyWith(loadingPicture: path);
    changeSiteSettingValueNotifier(siteSettingModel: setting);
  }

  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  @override
  void dispose() {
    dispositionalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingValueNotifier,
        builder: (context, isLoading, child) {
          return isLoading ? const LoadingWidget() : child!;
        },
        child: ValueListenableBuilder<SiteSettingModel>(
          valueListenable: siteSettingModelValueNotifier,
          builder: (context, setting, _) {
            return Padding(
              padding: const EdgeInsets.all(AppConfigs.largeVisualDensity),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppConfigs.appShadowColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppConfigs.mediumVisualDensity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Text(
                              AppTexts.loadingPicture,
                            ),
                            const CustomSpaceWidget(
                              sizeDirection: SizeDirection.horizontal,
                            ),
                            InkWell(
                              onTap: () {
                                context.readAppBloc.add(
                                  UploadImageEvent(
                                    afterFileUploaded: changeImageOfSettings,
                                  ),
                                );
                              },
                              child: SizedBox.square(
                                dimension: AppConfigs.xxxLargeVisualDensity * 2,
                                child: setting.loadingPicture.isEmpty
                                    ? const Text(AppTexts.datasNotFound)
                                    : Image.network(
                                        '${BaseConfigs.serveImage}${setting.loadingPicture}',
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const CustomSpaceWidget(),
                        Row(
                          children: [
                            const Text(
                              AppTexts.minDepositAmount,
                            ),
                            const CustomSpaceWidget(
                              sizeDirection: SizeDirection.horizontal,
                            ),
                            Expanded(
                              child: TextFormField(
                                validator: (String? value) {
                                  return (value ?? '').isEmpty
                                      ? AppTexts.pleaseEnterValidInput
                                      : null;
                                },
                                decoration:
                                    AppConfigs.customInputDecoration.copyWith(
                                  labelText: AppTexts.minDepositAmount,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                controller:
                                    minDepositAmountTextEditingController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const CustomSpaceWidget(),
                        Row(
                          children: [
                            const Text(
                              AppTexts.minWithdrawAmount,
                            ),
                            const CustomSpaceWidget(
                              sizeDirection: SizeDirection.horizontal,
                            ),
                            Expanded(
                              child: TextFormField(
                                validator: (String? value) {
                                  return (value ?? '').isEmpty
                                      ? AppTexts.pleaseEnterValidInput
                                      : null;
                                },
                                decoration:
                                    AppConfigs.customInputDecoration.copyWith(
                                  labelText: AppTexts.minWithdrawAmount,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                controller:
                                    minWithdrawAmountTextEditingController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const CustomSpaceWidget(),
                        Row(
                          children: [
                            const Text(
                              AppTexts.referalPercent,
                            ),
                            const CustomSpaceWidget(
                              sizeDirection: SizeDirection.horizontal,
                            ),
                            Expanded(
                              child: TextFormField(
                                validator: (String? value) {
                                  return (value ?? '').isEmpty
                                      ? AppTexts.pleaseEnterValidInput
                                      : null;
                                },
                                decoration:
                                    AppConfigs.customInputDecoration.copyWith(
                                  labelText: AppTexts.referalPercent,
                                ),
                                keyboardType: TextInputType.number,
                                controller: referalPercentTextEditingController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const CustomSpaceWidget(),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save_outlined),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.readAppBloc.add(
                                  CreateEditSettingModelEvent(
                                    loadingPicture:
                                        siteSettingModelValueNotifier
                                            .value.loadingPicture,
                                    minDepositAmount:
                                        minDepositAmountTextEditingController
                                            .text,
                                    minWithdrawAmount:
                                        minWithdrawAmountTextEditingController
                                            .text,
                                    referalPercent:
                                        referalPercentTextEditingController
                                            .text,
                                    afterSiteSettingModelCreated:
                                        changeSiteSettingValueNotifier,
                                  ),
                                );
                              }
                            },
                            label: const Text(
                              AppTexts.save,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
