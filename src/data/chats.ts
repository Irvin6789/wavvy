export type ChatItem = {
  name: string
  msg: string
  time: string
  unread: number
  online: boolean
  group: boolean
  initials: string
}

export const CHATS: ChatItem[] = [
  { name: 'Maya Khan',     msg: 'On my way! 🚗',                   time: 'now',  unread: 3, online: true,  group: false, initials: 'MK' },
  { name: 'Alex Liu',      msg: 'Did you see the game last night?', time: '2m',   unread: 1, online: true,  group: false, initials: 'AL' },
  { name: 'Weekend Squad', msg: "Ryan: I'll bring the drinks 🥤",  time: '18m',  unread: 7, online: false, group: true,  initials: 'WS' },
  { name: 'Sara Lee',      msg: 'Meeting confirmed ✅',             time: '1h',   unread: 0, online: false, group: false, initials: 'SL' },
  { name: 'Ryan J',        msg: "Let's catch up soon!",            time: '3h',   unread: 0, online: true,  group: false, initials: 'RJ' },
  { name: 'Dev Team',      msg: 'New PR ready for review 👀',      time: '5h',   unread: 2, online: false, group: true,  initials: 'DT' },
  { name: 'Mom',           msg: 'Call me when you can 💛',         time: 'Tue',  unread: 0, online: false, group: false, initials: 'MM' },
  { name: 'James B',       msg: 'Sent a voice message 🎙️',         time: 'Mon',  unread: 0, online: false, group: false, initials: 'JB' },
  { name: 'Design Crew',   msg: "Layla: Check the new mockups!",   time: 'Sun',  unread: 4, online: false, group: true,  initials: 'DC' },
  { name: 'Nora S',        msg: 'Thanks so much!! 🙏',             time: 'Sun',  unread: 0, online: false, group: false, initials: 'NS' },
  { name: 'Football Lads', msg: "Omar: We training tomorrow?",     time: 'Sat',  unread: 0, online: false, group: true,  initials: 'FL' },
  { name: 'Khalid R',      msg: 'Sent a photo 📷',                 time: 'Sat',  unread: 0, online: false, group: false, initials: 'KR' },
]

export type Message = {
  id: string
  text: string
  mine: boolean
  time: string
  status?: 'sent' | 'delivered' | 'read'
  sender?: string
  senderInitials?: string
  system?: boolean
  reaction?: string
}

export const MOCK_MESSAGES: Record<string, Message[]> = {
  'Maya Khan': [
    { id: '1', text: 'Hey! Are you coming tonight? 🎉', mine: false, time: '7:42 PM' },
    { id: '2', text: 'Yes! What time does it start?', mine: true, time: '7:44 PM', status: 'read' },
    { id: '3', text: 'Starts at 9, but come at 8:30 so we can catch up first 😊', mine: false, time: '7:45 PM' },
    { id: '4', text: 'Perfect, I\'ll be there!', mine: true, time: '7:46 PM', status: 'read' },
    { id: '5', text: 'Should I bring anything?', mine: true, time: '7:46 PM', status: 'read' },
    { id: '6', text: 'Just yourself! We\'ve got everything covered 🙌', mine: false, time: '7:48 PM' },
    { id: '7', text: 'On my way! 🚗', mine: false, time: 'now' },
  ],
  'Alex Liu': [
    { id: '1', text: 'Did you catch the game last night? 🏀', mine: false, time: '10:12 PM' },
    { id: '2', text: 'No I missed it, what happened?', mine: true, time: '10:20 PM', status: 'read' },
    { id: '3', text: 'Last second buzzer beater. Absolute madness 😭', mine: false, time: '10:21 PM' },
    { id: '4', text: 'Did you see the game last night?', mine: false, time: '2m ago' },
  ],
  'Sara Lee': [
    { id: '1', text: 'Hey, just confirming the 3pm meeting 🗓️', mine: false, time: '1:02 PM' },
    { id: '2', text: 'Yes, I\'ll be there. Should I prepare anything?', mine: true, time: '1:10 PM', status: 'read' },
    { id: '3', text: 'Just bring your laptop. We\'re reviewing the Q3 deck.', mine: false, time: '1:12 PM' },
    { id: '4', text: 'Got it!', mine: true, time: '1:13 PM', status: 'read' },
    { id: '5', text: 'Meeting confirmed ✅', mine: false, time: '1h ago' },
  ],
  'Ryan J': [
    { id: '1', text: 'Dude it\'s been ages 😅', mine: false, time: '10:00 AM' },
    { id: '2', text: 'I know! Been super busy lately', mine: true, time: '10:05 AM', status: 'read' },
    { id: '3', text: 'Same here. We should grab coffee sometime this week?', mine: false, time: '10:06 AM' },
    { id: '4', text: 'Let\'s catch up soon!', mine: false, time: '3h ago' },
  ],
  'Mom': [
    { id: '1', text: 'How are you doing sweetheart? 💛', mine: false, time: 'Tue 2:00 PM' },
    { id: '2', text: 'I\'m good Mom! Busy with work', mine: true, time: 'Tue 2:30 PM', status: 'read' },
    { id: '3', text: 'Don\'t forget to eat properly 🍲', mine: false, time: 'Tue 2:31 PM' },
    { id: '4', text: 'Call me when you can 💛', mine: false, time: 'Tue 3:00 PM' },
  ],
  'Weekend Squad': [
    { id: 'sys1', text: 'You were added to Weekend Squad', mine: false, time: 'Fri 7:00 PM', system: true },
    { id: '1', text: 'Who\'s free Saturday?', mine: false, time: 'Fri 8:00 PM', sender: 'Maya', senderInitials: 'MK' },
    { id: '2', text: 'I\'m in! 🙋', mine: true, time: 'Fri 8:05 PM', status: 'read' },
    { id: '3', text: 'Me too! What are we doing?', mine: false, time: 'Fri 8:07 PM', sender: 'Ryan', senderInitials: 'RJ' },
    { id: '4', text: 'Let\'s do rooftop? The weather looks great', mine: false, time: 'Fri 8:09 PM', sender: 'Maya', senderInitials: 'MK' },
    { id: '5', text: 'YES 🔥', mine: false, time: 'Fri 8:10 PM', sender: 'Sara', senderInitials: 'SL' },
    { id: '6', text: 'I\'ll bring the drinks 🥤', mine: false, time: '18m ago', sender: 'Ryan', senderInitials: 'RJ' },
  ],
  'Dev Team': [
    { id: 'sys1', text: 'Alex Liu created this group', mine: false, time: 'Mon 9:00 AM', system: true },
    { id: '1', text: 'Hey team! New sprint starts Monday', mine: false, time: 'Mon 9:05 AM', sender: 'Alex', senderInitials: 'AL' },
    { id: '2', text: 'On it! I\'ll start with the auth refactor', mine: true, time: 'Mon 9:10 AM', status: 'delivered' },
    { id: '3', text: 'I\'ll handle the API endpoints', mine: false, time: 'Mon 9:12 AM', sender: 'Nora', senderInitials: 'NS' },
    { id: '4', text: 'Design assets are ready in Figma btw 🎨', mine: false, time: 'Mon 9:15 AM', sender: 'Layla', senderInitials: 'LA' },
    { id: '5', text: 'Perfect! Let\'s sync at 2pm', mine: true, time: 'Mon 9:20 AM', status: 'read' },
    { id: '6', text: 'New PR ready for review 👀', mine: false, time: '5h ago', sender: 'Alex', senderInitials: 'AL' },
  ],
  'Design Crew': [
    { id: 'sys1', text: 'Layla added you to Design Crew', mine: false, time: 'Sun 10:00 AM', system: true },
    { id: '1', text: 'Check the new mockups!', mine: false, time: 'Sun 10:05 AM', sender: 'Layla', senderInitials: 'LA' },
    { id: '2', text: 'These look incredible 🔥', mine: true, time: 'Sun 10:15 AM', status: 'read' },
    { id: '3', text: 'Love the color palette!', mine: false, time: 'Sun 10:16 AM', sender: 'Nora', senderInitials: 'NS' },
    { id: '4', text: 'The spacing feels off on mobile though', mine: false, time: 'Sun 10:20 AM', sender: 'James', senderInitials: 'JB' },
    { id: '5', text: 'Good catch, I\'ll fix that', mine: false, time: 'Sun 10:22 AM', sender: 'Layla', senderInitials: 'LA' },
  ],
  'Football Lads': [
    { id: 'sys1', text: 'Omar added you to Football Lads', mine: false, time: 'Sat 6:00 PM', system: true },
    { id: '1', text: 'We training tomorrow?', mine: false, time: 'Sat 6:05 PM', sender: 'Omar', senderInitials: 'OM' },
    { id: '2', text: 'Yeah 7am at the usual spot', mine: true, time: 'Sat 6:10 PM', status: 'delivered' },
    { id: '3', text: 'Can\'t make it, have work 😭', mine: false, time: 'Sat 6:15 PM', sender: 'Khalid', senderInitials: 'KR' },
    { id: '4', text: 'No worries, we\'ll record the highlights 😂', mine: false, time: 'Sat 6:17 PM', sender: 'Omar', senderInitials: 'OM' },
  ],
}

export type NewChatItem = {
  initials: string
  name: string
  msg: string
  time: string
  online: boolean
  group: boolean
}

export const NEW_CHAT_ITEMS: NewChatItem[] = [
  { initials: 'MK', name: 'Maya Khan',     msg: 'On my way! 🚗',                   time: 'now',  online: true,  group: false },
  { initials: 'AL', name: 'Alex Liu',      msg: 'Did you see the game last night?', time: '2m',   online: true,  group: false },
  { initials: 'WS', name: 'Weekend Squad', msg: '4 members • public group',         time: '',     online: false, group: true  },
  { initials: 'SL', name: 'Sara Lee',      msg: 'Meeting confirmed ✅',             time: '1h',   online: false, group: false },
  { initials: 'RJ', name: 'Ryan J',        msg: "Let's catch up soon!",            time: '3h',   online: true,  group: false },
  { initials: 'DT', name: 'Dev Team',      msg: '12 members • private group',       time: '',     online: false, group: true  },
  { initials: 'MM', name: 'Mom',           msg: 'Call me when you can 💛',         time: 'Tue',  online: false, group: false },
  { initials: 'JB', name: 'James B',       msg: 'Sent a voice message 🎙️',         time: 'Mon',  online: false, group: false },
  { initials: 'DC', name: 'Design Crew',   msg: '7 members • public group',         time: '',     online: false, group: true  },
  { initials: 'NS', name: 'Nora S',        msg: 'Thanks so much!! 🙏',             time: 'Sun',  online: false, group: false },
  { initials: 'FL', name: 'Football Lads', msg: '9 members • public group',         time: '',     online: false, group: true  },
  { initials: 'KR', name: 'Khalid R',      msg: 'Sent a photo 📷',                 time: 'Sat',  online: false, group: false },
]
