import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:day11_api_gemini/services/gemini_api.dart';
import 'package:flutter/material.dart';

// ---- girly palette (top level) ----
const blush = Color(0xFFFFF0F5);
const softPink = Color(0xFFFFC1D8);
const hotPink = Color(0xFFFF6FA5);
const lavender = Color(0xFFD9B8FF);
const plum = Color(0xFF7A4E7E);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatUser user1 = ChatUser(id: '1', firstName: 'Latifa');
  ChatUser user2 = ChatUser(id: '2', firstName: 'Bot');

  List<ChatMessage> messagesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF8FB1), lavender]),
          ),
        ),
        title: const Text(
          "Your Fav Assistant",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [blush, Colors.white],
          ),
        ),
        child: DashChat(
          currentUser: user1,
          messageOptions: MessageOptions(
            showTime: true,
            borderRadius: 22,
            messagePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            currentUserTextColor: Colors.white,
            textColor: plum,
            messageDecorationBuilder: (msg, prev, next) {
              final isMe = msg.user.id == user1.id;
              return BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFFFF8FB1), lavender],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : softPink.withOpacity(.35),
                boxShadow: [
                  BoxShadow(
                    color: hotPink.withOpacity(.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              );
            },
            avatarBuilder: (u, onPressAvatar, onLongPressAvatar) => Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [hotPink, lavender]),
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage("assets/images/AI_Icon.png"),
              ),
            ),
          ),
          inputOptions: InputOptions(
            cursorStyle: const CursorStyle(color: hotPink),
            inputTextStyle: const TextStyle(color: plum),
            inputToolbarStyle: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: hotPink.withOpacity(.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            inputToolbarMargin: const EdgeInsets.all(12),
            inputToolbarPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            inputDecoration: const InputDecoration(
              hintText: "Type something...",
              hintStyle: TextStyle(color: Color(0xFFB98BC9)),
              border: InputBorder.none,
            ),
            sendButtonBuilder: (send) => IconButton(
              icon: const Icon(Icons.favorite_rounded, color: hotPink),
              onPressed: send,
            ),
          ),
          onSend: (messages) async {
            messagesList.insert(0, messages);
            setState(() {});

            try {
              String botMessage = await GeminiApi().sendRequest(messages.text);
              ChatMessage reply = ChatMessage(
                user: user2,
                createdAt: DateTime.now(),
                text: botMessage,
              );
              messagesList.insert(0, reply);
            } catch (e) {
              print("ERROR: $e");
              messagesList.insert(
                0,
                ChatMessage(
                  user: user2,
                  createdAt: DateTime.now(),
                  text: "Oops, something went wrong. Try again?",
                ),
              );
            }
            setState(() {});
          },
          messages: messagesList,
        ),
      ),
    );
  }
}