import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/models/websocket_server_model.dart';
import 'package:winball/utils/functions.dart';

class CurrentOneMinGameDetailsWidget extends StatelessWidget {
  const CurrentOneMinGameDetailsWidget({
    super.key,
    required this.currentWebsocketServerModelValueNotifier,
    required this.currentGameTimerValueNotifier,
    required this.functions,
  });

  final ValueNotifier<WebsocketServerModel>
      currentWebsocketServerModelValueNotifier;
  final ValueNotifier<int> currentGameTimerValueNotifier;
  final Functions functions;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WebsocketServerModel>(
      valueListenable: currentWebsocketServerModelValueNotifier,
      builder: (context, websocketModel, _) {
        return Text(
          '${AppTexts.randomNo}${websocketModel.oneMinGame.eachGameUniqueNumber}',
        );
      },
    );
  }
}
