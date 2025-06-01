import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:slider_repository/slider_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/app_configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/global/custom_error_widget.dart';
import 'package:winball_admin_panel/widgets/global/custom_space_widget.dart';
import 'package:winball_admin_panel/widgets/global/loading_widget.dart';



class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<SliderModel>> listOfSliderValueNotifier;
  late final ValueNotifier<bool> isRefreshingValueNotifier;
  late final SliderRepositoryFunctions sliderRepositoryFunctions;
  
  Future<void> initializeDatas() async {
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    listOfSliderValueNotifier = ValueNotifier<List<SliderModel>>([]);
    isRefreshingValueNotifier = ValueNotifier<bool>(false);
    sliderRepositoryFunctions = const SliderRepositoryFunctions();
    
    await _loadSliders();
  }

  Future<void> _loadSliders() async {
    final AppBloc appBloc = context.readAppBloc;
    
    try {
      final List<SliderModel> sliders = await sliderRepositoryFunctions.getSlider(
          token: appBloc.state.currentUser.token ?? '',
      );
      
      if (mounted) {
        changeListOfSliderValueNotifier(sliders: sliders);
        changeIsLoadingValueNotifier(isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        changeIsLoadingValueNotifier(isLoading: false);
      appBloc.addError(e);
      }
    }
  }

  Future<void> refreshData() async {
    if (isLoadingValueNotifier.value || isRefreshingValueNotifier.value) return;
    
    changeIsRefreshingValueNotifier(isRefreshing: true);
    
    try {
      await _loadSliders();
    } finally {
      if (mounted) {
        changeIsRefreshingValueNotifier(isRefreshing: false);
      }
    }
  }

  void dispositionalDatas() {
    isLoadingValueNotifier.dispose();
    listOfSliderValueNotifier.dispose();
    isRefreshingValueNotifier.dispose();
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    if (mounted) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
    }
  }

  void changeIsRefreshingValueNotifier({bool? isRefreshing}) {
    if (mounted) {
      isRefreshingValueNotifier.value = isRefreshing ?? !isRefreshingValueNotifier.value;
    }
  }

  void changeListOfSliderValueNotifier({required List<SliderModel> sliders}) {
    if (mounted) {
    listOfSliderValueNotifier.value = sliders;
    }
  }

  void deleteSliderModel({required int sliderId}) {
    final List<SliderModel> sliders = List.from(listOfSliderValueNotifier.value);
    sliders.removeWhere((e) => e.id == sliderId);
    changeListOfSliderValueNotifier(sliders: sliders);
  }

  void addSliderToListOfSliderValueNotifier({required SliderModel sliderModel}) {
    final List<SliderModel> sliders = List.from(listOfSliderValueNotifier.value);
    sliders.add(sliderModel);
    changeListOfSliderValueNotifier(sliders: sliders);
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

  void createSliderModel({required String path}) {
    context.readAppBloc.add(
      CreateSliderEvent(
        imagePath: path,
        afterSliderCreated: addSliderToListOfSliderValueNotifier,
      ),
    );
  }

  Widget _buildOptimizedImage(SliderModel sliderModel) {
    final String imageUrl = '${BaseConfigs.serveImage}${sliderModel.imagePath}';
    
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Colors.red[400],
              size: 40,
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading Failed',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'ID: ${sliderModel.id}',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = context.getSize;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slider Management'),
        backgroundColor: AppConfigs.lightBlueButtonColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: isRefreshingValueNotifier,
            builder: (context, isRefreshing, _) {
              return IconButton(
                icon: isRefreshing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: isRefreshing ? null : refreshData,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_outlined),
            tooltip: 'Add new slider',
            onPressed: () {
              context.readAppBloc.add(
                UploadImageEvent(
                  afterFileUploaded: createSliderModel,
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingValueNotifier,
        builder: (context, isLoading, child) {
          return isLoading ? const LoadingWidget() : child!;
        },
        child: ValueListenableBuilder<List<SliderModel>>(
          valueListenable: listOfSliderValueNotifier,
          builder: (context, sliders, _) {
            return sliders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No sliders available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click + to add a new slider',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.readAppBloc.add(
                              UploadImageEvent(
                                afterFileUploaded: createSliderModel,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Slider'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfigs.lightBlueButtonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: refreshData,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width.isMobile ? 2 : 4,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                    ),
                    itemCount: sliders.length,
                    itemBuilder: (context, index) {
                      final SliderModel sliderModel = sliders[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: _buildOptimizedImage(sliderModel),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppConfigs.lightBlueButtonColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'ID: ${sliderModel.id}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppConfigs.lightBlueButtonColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppConfigs.redColor,
                                      ),
                                      tooltip: 'Delete slider',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            title: const Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_outlined,
                                                  color: AppConfigs.redColor,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Confirm Delete'),
                                              ],
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this slider? This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppConfigs.redColor,
                                                  foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                                                  Navigator.pop(context);
                              context.readAppBloc.add(
                                RemoveSliderEvent(
                                  sliderId: sliderModel.id,
                                  afterSliderRemoved: deleteSliderModel,
                                ),
                              );
                            },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          ),
                        ],
                          ),
                      );
                    },
                    ),
                  );
          },
        ),
      ),
    );
  }
}
