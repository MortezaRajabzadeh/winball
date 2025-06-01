import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:slider_repository/slider_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/models/models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({
    super.key,
    required this.sliders,
    required this.pageController,
    required this.changeSliderIndexValueNotifier,
  });
  final List<SliderModel> sliders;
  final PageController pageController;
  final void Function({required int index}) changeSliderIndexValueNotifier;

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(SliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) {
      return const SizedBox.shrink();
    }

    // محاسبه ارتفاع بر اساس نسبت 16:9
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sliderHeight = (screenWidth * 9) / 16;

    final List<Widget> items = [];
    for (var i = 0; i < widget.sliders.length; i++) {
      final slider = widget.sliders[i];
      if (slider.imagePath == null || slider.imagePath!.isEmpty) {
        items.add(
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConfigs.mediumVisualDensity),
              child: Container(
                color: Colors.grey[900],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            ),
          ),
        );
        continue;
      }

      final String imageUrl = '${BaseConfigs.serveImage}${slider.imagePath}';
      items.add(
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConfigs.mediumVisualDensity),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              memCacheWidth: 800,
              memCacheHeight: 450,
              filterQuality: FilterQuality.medium,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppConfigs.yellowColor,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return FlutterCarousel(
      items: items,
      options: FlutterCarouselOptions(
        height: sliderHeight,
        viewportFraction: 1.0,
        initialPage: 0,
        enableInfiniteScroll: items.length > 1,
        reverse: false,
        autoPlay: items.length > 1,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        showIndicator: false,
        onPageChanged: (index, reason) {
          if (index >= 0 && index < items.length && items.isNotEmpty) {
            setState(() {
              _currentIndex = index;
            });
            widget.changeSliderIndexValueNotifier(index: index);
          }
        },
      ),
    );
  }
}
