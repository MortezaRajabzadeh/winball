import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:winball/configs/configs.dart';

class SliderWidget extends StatelessWidget {
  const SliderWidget({
    super.key,
    required this.sliderImages,
    required this.changeSliderIndexValueNotifier,
  });
  final List<String> sliderImages;
  final void Function({required int index}) changeSliderIndexValueNotifier;

  @override
  Widget build(BuildContext context) {
    if (sliderImages.isEmpty) {
      return Container(
        height: AppConfigs.sliderHeight,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppConfigs.mediumVisualDensity),
        ),
        child: const Center(
          child: Text('No slider images found'),
        ),
      );
    }
    
    return FlutterCarousel(
      options: FlutterCarouselOptions(
        height: AppConfigs.sliderHeight,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 7),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOut,
        enableInfiniteScroll: true,
        showIndicator: false, // We're using external indicator
        onPageChanged: (int index, CarouselPageChangedReason reason) {
          changeSliderIndexValueNotifier(index: index);
        },
        pauseAutoPlayOnTouch: true,
        pauseAutoPlayOnManualNavigate: false,
        pauseAutoPlayInFiniteScroll: false,
        padEnds: false,
      ),
      items: sliderImages.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfigs.largeVisualDensity,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppConfigs.mediumVisualDensity,
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.withOpacity(0.2),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
