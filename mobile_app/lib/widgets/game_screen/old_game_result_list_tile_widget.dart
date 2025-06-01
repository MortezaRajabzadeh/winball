import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/utils/functions.dart';

class OldGameResultListTileWidget extends StatefulWidget {
  const OldGameResultListTileWidget({
    super.key,
    required this.result,
    required this.listWheelScrollController,
    required this.functions,
    required this.oldOneMinGameId,
    required this.scrollListWheelScrollControllerByGameResult,
  });
  final void Function({required OneMinGameResult gameResult})
      scrollListWheelScrollControllerByGameResult;

  final OneMinGameResult? result;
  final ScrollController listWheelScrollController;
  final Functions functions;
  final int oldOneMinGameId;

  @override
  State<OldGameResultListTileWidget> createState() =>
      _OldGameResultListTileWidgetState();
}

class _OldGameResultListTileWidgetState
    extends State<OldGameResultListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(
      '${AppTexts.randomNo}${widget.oldOneMinGameId}',
      style: AppConfigs.timerWhiteTextStyle,
    );
    // ListTile(
    //   contentPadding: EdgeInsets.zero,
    //   title: Text('${AppTexts.randomNo}${widget.oldOneMinGameId}'),
    //   trailing: widget.result != null
    //       ? SizedBox(
    //           width: AppConfigs.listWheelItemExtentWidth,
    //           height: AppConfigs.listWheelItemExtentHeight,
    //           child: GestureDetector(
    //             onTap: () {
    //               loadOneMinGames();
    //               showAdaptiveDialog(
    //                 context: context,
    //                 builder: (context) {
    //                   final Size size = context.getSize;
    //                   return AlertDialog.adaptive(
    //                     actions: [
    //                       TextButton(
    //                         onPressed: context.pop,
    //                         child: const Text(
    //                           AppTexts.close,
    //                         ),
    //                       ),
    //                     ],
    //                     content: Column(
    //                       mainAxisSize: MainAxisSize.min,
    //                       children: [
    //                         ValueListenableBuilder<List<OneMinGameModel>>(
    //                           valueListenable:
    //                               listOfOldOneMinGamesValueNotifier,
    //                           builder: (context, games, _) {
    //                             return games.isEmpty
    //                                 ? const CustomErrorWidget()
    //                                 : SizedBox(
    //                                     height: context.getSize.height / 2,
    //                                     width: size.width -
    //                                         AppConfigs.largeVisualDensity,
    //                                     child: ListView.builder(
    //                                       itemCount: games.length,
    //                                       itemBuilder: (context, index) {
    //                                         final OneMinGameResult? gameResult =
    //                                             games[index].gameResult;
    //                                         return ListTile(
    //                                           contentPadding: EdgeInsets.zero,
    //                                           title: Text(
    //                                               '${AppTexts.randomNo}${games[index].id}'),
    //                                           trailing: gameResult == null
    //                                               ? null
    //                                               : NumberAndCirclesByOneMinGameResultWidget(
    //                                                   functions:
    //                                                       widget.functions,
    //                                                   oneMinGameResult:
    //                                                       gameResult,
    //                                                 ),
    //                                         );
    //                                       },
    //                                     ),
    //                                   );
    //                           },
    //                         ),
    //                         ValueListenableBuilder<bool>(
    //                           valueListenable: isLoadingValueNotifier,
    //                           builder: (context, isLoading, child) {
    //                             return isLoading
    //                                 ? const LoadingWidget()
    //                                 : child!;
    //                           },
    //                           child: ValueListenableBuilder<bool>(
    //                             valueListenable: hasMoreDataValueNotifier,
    //                             builder: (context, hasMoreDatas, _) {
    //                               return TextButton(
    //                                 onPressed:
    //                                     hasMoreDatas ? loadOneMinGames : null,
    //                                 style: const ButtonStyle(
    //                                   foregroundColor:
    //                                       WidgetStatePropertyAll<Color>(
    //                                     AppConfigs.yellowColor,
    //                                   ),
    //                                 ),
    //                                 child: const Text(
    //                                   AppTexts.loadMore,
    //                                 ),
    //                               );
    //                             },
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   );
    //                 },
    //               );
    //             },
    //             child: ListWheelScrollView(
    //               physics: const NeverScrollableScrollPhysics(),
    //               // offAxisFraction: -0.5,
    //               // offAxisFraction: -0.5,
    //               clipBehavior: Clip.hardEdge,
    //               controller: widget.listWheelScrollController,
    //               perspective: 0.010,
    //               itemExtent: AppConfigs.listWheelItemExtentHeight,
    //               children: List.generate(
    //                 OneMinGameResult.values.length,
    //                 (index) => NumberAndCirclesByOneMinGameResultWidget(
    //                   functions: widget.functions,
    //                   oneMinGameResult:
    //                       OneMinGameResult.values.elementAt(index),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         )
    //       : null,
    // );
  }
}
