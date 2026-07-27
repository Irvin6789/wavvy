/// Ported from `src/data/chats.ts`.
import 'package:flutter/foundation.dart';

@immutable
class ChatItem {
  const ChatItem({
    required this.name,
    required this.msg,
    required this.time,
    required this.unread,
    required this.online,
    required this.group,
    required this.initials,
  });

  final String name;
  final String msg;
  final String time;
  final int unread;
  final bool online;
  final bool group;
  final String initials;
}

const List<ChatItem> kChats = <ChatItem>[
  ChatItem(name: 'Maya Khan', msg: 'On my way! 🚗', time: 'now', unread: 3, online: true, group: false, initials: 'MK'),
  ChatItem(name: 'Alex Liu', msg: 'Did you see the game last night?', time: '2m', unread: 1, online: true, group: false, initials: 'AL'),
  ChatItem(name: 'Weekend Squad', msg: "Ryan: I'll bring the drinks 🥤", time: '18m', unread: 7, online: false, group: true, initials: 'WS'),
  ChatItem(name: 'Sara Lee', msg: 'Meeting confirmed ✅', time: '1h', unread: 0, online: false, group: false, initials: 'SL'),
  ChatItem(name: 'Ryan J', msg: "Let's catch up soon!", time: '3h', unread: 0, online: true, group: false, initials: 'RJ'),
  ChatItem(name: 'Dev Team', msg: 'New PR ready for review 👀', time: '5h', unread: 2, online: false, group: true, initials: 'DT'),
  ChatItem(name: 'Mom', msg: 'Call me when you can 💛', time: 'Tue', unread: 0, online: false, group: false, initials: 'MM'),
  ChatItem(name: 'James B', msg: 'Sent a voice message 🎙️', time: 'Mon', unread: 0, online: false, group: false, initials: 'JB'),
  ChatItem(name: 'Design Crew', msg: 'Layla: Check the new mockups!', time: 'Sun', unread: 4, online: false, group: true, initials: 'DC'),
  ChatItem(name: 'Nora S', msg: 'Thanks so much!! 🙏', time: 'Sun', unread: 0, online: false, group: false, initials: 'NS'),
  ChatItem(name: 'Football Lads', msg: 'Omar: We training tomorrow?', time: 'Sat', unread: 0, online: false, group: true, initials: 'FL'),
  ChatItem(name: 'Khalid R', msg: 'Sent a photo 📷', time: 'Sat', unread: 0, online: false, group: false, initials: 'KR'),
];

enum MessageStatus { sent, delivered, read }

@immutable
class Message {
  const Message({
    required this.id,
    required this.text,
    required this.mine,
    required this.time,
    this.status,
    this.sender,
    this.senderInitials,
    this.system = false,
  });

  final String id;
  final String text;
  final bool mine;
  final String time;
  final MessageStatus? status;
  final String? sender;
  final String? senderInitials;
  final bool system;
}

const Map<String, List<Message>> kMockMessages = <String, List<Message>>{
  'Maya Khan': <Message>[
    Message(id: '1', text: 'Hey! Are you coming tonight? 🎉', mine: false, time: '7:42 PM'),
    Message(id: '2', text: 'Yes! What time does it start?', mine: true, time: '7:44 PM', status: MessageStatus.read),
    Message(id: '3', text: 'Starts at 9, but come at 8:30 so we can catch up first 😊', mine: false, time: '7:45 PM'),
    Message(id: '4', text: "Perfect, I'll be there!", mine: true, time: '7:46 PM', status: MessageStatus.read),
    Message(id: '5', text: 'Should I bring anything?', mine: true, time: '7:46 PM', status: MessageStatus.read),
    Message(id: '6', text: "Just yourself! We've got everything covered 🙌", mine: false, time: '7:48 PM'),
    Message(id: '7', text: 'On my way! 🚗', mine: false, time: 'now'),
  ],
  'Alex Liu': <Message>[
    Message(id: '1', text: 'Did you catch the game last night? 🏀', mine: false, time: '10:12 PM'),
    Message(id: '2', text: 'No I missed it, what happened?', mine: true, time: '10:20 PM', status: MessageStatus.read),
    Message(id: '3', text: 'Last second buzzer beater. Absolute madness 😭', mine: false, time: '10:21 PM'),
    Message(id: '4', text: 'Did you see the game last night?', mine: false, time: '2m ago'),
  ],
  'Sara Lee': <Message>[
    Message(id: '1', text: 'Hey, just confirming the 3pm meeting 🗓️', mine: false, time: '1:02 PM'),
    Message(id: '2', text: "Yes, I'll be there. Should I prepare anything?", mine: true, time: '1:10 PM', status: MessageStatus.read),
    Message(id: '3', text: "Just bring your laptop. We're reviewing the Q3 deck.", mine: false, time: '1:12 PM'),
    Message(id: '4', text: 'Got it!', mine: true, time: '1:13 PM', status: MessageStatus.read),
    Message(id: '5', text: 'Meeting confirmed ✅', mine: false, time: '1h ago'),
  ],
  'Ryan J': <Message>[
    Message(id: '1', text: "Dude it's been ages 😅", mine: false, time: '10:00 AM'),
    Message(id: '2', text: 'I know! Been super busy lately', mine: true, time: '10:05 AM', status: MessageStatus.read),
    Message(id: '3', text: 'Same here. We should grab coffee sometime this week?', mine: false, time: '10:06 AM'),
    Message(id: '4', text: "Let's catch up soon!", mine: false, time: '3h ago'),
  ],
  'Mom': <Message>[
    Message(id: '1', text: 'How are you doing sweetheart? 💛', mine: false, time: 'Tue 2:00 PM'),
    Message(id: '2', text: "I'm good Mom! Busy with work", mine: true, time: 'Tue 2:30 PM', status: MessageStatus.read),
    Message(id: '3', text: "Don't forget to eat properly 🍲", mine: false, time: 'Tue 2:31 PM'),
    Message(id: '4', text: 'Call me when you can 💛', mine: false, time: 'Tue 3:00 PM'),
  ],
  'Weekend Squad': <Message>[
    Message(id: 'sys1', text: 'You were added to Weekend Squad', mine: false, time: 'Fri 7:00 PM', system: true),
    Message(id: '1', text: "Who's free Saturday?", mine: false, time: 'Fri 8:00 PM', sender: 'Maya', senderInitials: 'MK'),
    Message(id: '2', text: "I'm in! 🙋", mine: true, time: 'Fri 8:05 PM', status: MessageStatus.read),
    Message(id: '3', text: 'Me too! What are we doing?', mine: false, time: 'Fri 8:07 PM', sender: 'Ryan', senderInitials: 'RJ'),
    Message(id: '4', text: "Let's do rooftop? The weather looks great", mine: false, time: 'Fri 8:09 PM', sender: 'Maya', senderInitials: 'MK'),
    Message(id: '5', text: 'YES 🔥', mine: false, time: 'Fri 8:10 PM', sender: 'Sara', senderInitials: 'SL'),
    Message(id: '6', text: "I'll bring the drinks 🥤", mine: false, time: '18m ago', sender: 'Ryan', senderInitials: 'RJ'),
  ],
  'Dev Team': <Message>[
    Message(id: 'sys1', text: 'Alex Liu created this group', mine: false, time: 'Mon 9:00 AM', system: true),
    Message(id: '1', text: 'Hey team! New sprint starts Monday', mine: false, time: 'Mon 9:05 AM', sender: 'Alex', senderInitials: 'AL'),
    Message(id: '2', text: "On it! I'll start with the auth refactor", mine: true, time: 'Mon 9:10 AM', status: MessageStatus.delivered),
    Message(id: '3', text: "I'll handle the API endpoints", mine: false, time: 'Mon 9:12 AM', sender: 'Nora', senderInitials: 'NS'),
    Message(id: '4', text: 'Design assets are ready in Figma btw 🎨', mine: false, time: 'Mon 9:15 AM', sender: 'Layla', senderInitials: 'LA'),
    Message(id: '5', text: "Perfect! Let's sync at 2pm", mine: true, time: 'Mon 9:20 AM', status: MessageStatus.read),
    Message(id: '6', text: 'New PR ready for review 👀', mine: false, time: '5h ago', sender: 'Alex', senderInitials: 'AL'),
  ],
  'Design Crew': <Message>[
    Message(id: 'sys1', text: 'Layla added you to Design Crew', mine: false, time: 'Sun 10:00 AM', system: true),
    Message(id: '1', text: 'Check the new mockups!', mine: false, time: 'Sun 10:05 AM', sender: 'Layla', senderInitials: 'LA'),
    Message(id: '2', text: 'These look incredible 🔥', mine: true, time: 'Sun 10:15 AM', status: MessageStatus.read),
    Message(id: '3', text: 'Love the color palette!', mine: false, time: 'Sun 10:16 AM', sender: 'Nora', senderInitials: 'NS'),
    Message(id: '4', text: 'The spacing feels off on mobile though', mine: false, time: 'Sun 10:20 AM', sender: 'James', senderInitials: 'JB'),
    Message(id: '5', text: "Good catch, I'll fix that", mine: false, time: 'Sun 10:22 AM', sender: 'Layla', senderInitials: 'LA'),
  ],
  'Football Lads': <Message>[
    Message(id: 'sys1', text: 'Omar added you to Football Lads', mine: false, time: 'Sat 6:00 PM', system: true),
    Message(id: '1', text: 'We training tomorrow?', mine: false, time: 'Sat 6:05 PM', sender: 'Omar', senderInitials: 'OM'),
    Message(id: '2', text: 'Yeah 7am at the usual spot', mine: true, time: 'Sat 6:10 PM', status: MessageStatus.delivered),
    Message(id: '3', text: "Can't make it, have work 😭", mine: false, time: 'Sat 6:15 PM', sender: 'Khalid', senderInitials: 'KR'),
    Message(id: '4', text: "No worries, we'll record the highlights 😂", mine: false, time: 'Sat 6:17 PM', sender: 'Omar', senderInitials: 'OM'),
  ],
};

@immutable
class NewChatItem {
  const NewChatItem({
    required this.initials,
    required this.name,
    required this.msg,
    required this.time,
    required this.online,
    required this.group,
  });

  final String initials;
  final String name;
  final String msg;
  final String time;
  final bool online;
  final bool group;
}

const List<NewChatItem> kNewChatItems = <NewChatItem>[
  NewChatItem(initials: 'MK', name: 'Maya Khan', msg: 'On my way! 🚗', time: 'now', online: true, group: false),
  NewChatItem(initials: 'AL', name: 'Alex Liu', msg: 'Did you see the game last night?', time: '2m', online: true, group: false),
  NewChatItem(initials: 'WS', name: 'Weekend Squad', msg: '4 members • public group', time: '', online: false, group: true),
  NewChatItem(initials: 'SL', name: 'Sara Lee', msg: 'Meeting confirmed ✅', time: '1h', online: false, group: false),
  NewChatItem(initials: 'RJ', name: 'Ryan J', msg: "Let's catch up soon!", time: '3h', online: true, group: false),
  NewChatItem(initials: 'DT', name: 'Dev Team', msg: '12 members • private group', time: '', online: false, group: true),
  NewChatItem(initials: 'MM', name: 'Mom', msg: 'Call me when you can 💛', time: 'Tue', online: false, group: false),
  NewChatItem(initials: 'JB', name: 'James B', msg: 'Sent a voice message 🎙️', time: 'Mon', online: false, group: false),
  NewChatItem(initials: 'DC', name: 'Design Crew', msg: '7 members • public group', time: '', online: false, group: true),
  NewChatItem(initials: 'NS', name: 'Nora S', msg: 'Thanks so much!! 🙏', time: 'Sun', online: false, group: false),
  NewChatItem(initials: 'FL', name: 'Football Lads', msg: '9 members • public group', time: '', online: false, group: true),
  NewChatItem(initials: 'KR', name: 'Khalid R', msg: 'Sent a photo 📷', time: 'Sat', online: false, group: false),
];
