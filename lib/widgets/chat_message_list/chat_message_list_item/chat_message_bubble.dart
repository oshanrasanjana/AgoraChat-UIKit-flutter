import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../agora_chat_uikit.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.model,
    required this.childBuilder,
    this.unreadFlagBuilder,
    this.onTap,
    this.onBubbleLongPress,
    this.onBubbleDoubleTap,
    this.avatarBuilder,
    this.nicknameBuilder,
    this.onResendTap,
    this.bubbleColor,
    this.padding,
    this.maxWidth,
    this.timeStyle,
    this.showTime = true,
  });

  final double? maxWidth;
  final ChatMessageListItemModel model;
  final ChatMessageTapAction? onTap;
  final ChatMessageTapAction? onBubbleLongPress;
  final ChatMessageTapAction? onBubbleDoubleTap;
  final ChatWidgetBuilder? avatarBuilder;
  final ChatWidgetBuilder? nicknameBuilder;

  final VoidCallback? onResendTap;
  final WidgetBuilder childBuilder;
  final WidgetBuilder? unreadFlagBuilder;
  final Color? bubbleColor;
  final EdgeInsets? padding;
  final TextStyle? timeStyle;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    double max = maxWidth ?? MediaQuery.of(context).size.width * 0.7;
    final boxConstraints = BoxConstraints(maxWidth: max);
    ChatMessage message = model.message;
    bool isLeft = message.direction == MessageDirection.RECEIVE;
    Widget content = Container(
      decoration: BoxDecoration(
        color: bubbleColor ??
            (isLeft
                ? ChatUIKit.of(context)?.theme.receiveBubbleColor ??
                    const Color.fromRGBO(242, 242, 242, 1)
                : ChatUIKit.of(context)?.theme.sendBubbleColor ??
                    const Color.fromRGBO(0, 65, 255, 1)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft:
              !isLeft ? const Radius.circular(10) : const Radius.circular(3),
          bottomRight:
              isLeft ? const Radius.circular(10) : const Radius.circular(3),
        ),
      ),
      constraints: boxConstraints,
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          
       crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(flex: 1, child: childBuilder(context)),
            if (showTime) ...[
              SizedBox(width: 12),
               Text(
                  _timeFromTimeStamp(message.serverTime),
                  style: timeStyle ??
                      const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              
            ]
          ],
        ),
      ),
    );

    if (!isLeft) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
       crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          content,
          SizedBox(height: 4),
          Align(
            alignment: Alignment.topRight,
            child: ChatMessageStatusWidget(message, onTap: onResendTap),
          ),
        ],
      );
    }

    List<Widget> insideBubbleWidgets = [];

    if (nicknameBuilder != null) {
      insideBubbleWidgets.add(
        Container(
          constraints: boxConstraints,
          child: nicknameBuilder!.call(context, message.from!),
        ),
      );

      insideBubbleWidgets.add(Flexible(flex: 1, child: content));

      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: insideBubbleWidgets.toList(),
      );
      insideBubbleWidgets.clear();
    }

    if (avatarBuilder != null) {
      insideBubbleWidgets.add(avatarBuilder!.call(context, message.from!));
      insideBubbleWidgets.add(const SizedBox(width: 10));
    }

    insideBubbleWidgets.add(Flexible(flex: 1, child: content));
    insideBubbleWidgets.add(SizedBox(width: isLeft ? 0 : 10.4));

    content = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: isLeft ? TextDirection.ltr : TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: insideBubbleWidgets.toList(),
    );

    insideBubbleWidgets.clear();

    if (unreadFlagBuilder != null && isLeft) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          content,
          const SizedBox(
            width: 10,
          ),
          unreadFlagBuilder!.call(context)
        ],
      );
    }

    content = Padding(
      padding: EdgeInsets.fromLTRB(12, 4, isLeft ? 8 : 12, 4),
      child: content,
    );

    content = InkWell(
      onDoubleTap: () => onBubbleDoubleTap?.call(context, message),
      onTap: () => onTap?.call(context, message),
      onLongPress: () => onBubbleLongPress?.call(context, message),
      child: content,
    );

    // if (model.needTime) {
    //   content = Column(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       Center(
    //         child: Padding(
    //           padding: const EdgeInsets.only(top: 10),
    //           child: SizedBox(
    //             height: 20,
    //             child: Text(
    //               TimeTool.timeStrByMs(message.serverTime),
    //               style: ChatUIKit.of(context)?.theme.messagesListItemTsStyle ??
    //                   const TextStyle(color: Colors.grey, fontSize: 14),
    //             ),
    //           ),
    //         ),
    //       ),
    //       content
    //     ],
    //   );
    // }
    return content;
  }
}

String _timeFromTimeStamp(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return intl.DateFormat('HH:mm').format(dateTime);
}
