import "phoenix_html"

import socket from "./socket"

import LivePolls from './poll'
LivePolls.connect(socket)

import LiveChat from './chat'
LiveChat.connect(socket)

