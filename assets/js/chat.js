const pushMessage = (channel, author, message) => {
  channel.push("new_message", { author, message })
    .receive("ok", res => console.log("Message send!"))
    .receive("error", res => console.log("Faild to send message:", res))
}

const addMessage = (author, message) => {
  const chatLog = document.querySelector(".chat-messages")
  chatLog.innerHTML += `<li>
    <span class="author">&lt;${author}&gt;</span>
    <span class="message">${message}</span>
  </li>
  `
}

const onJoin = (res, channel) => {
  document.querySelectorAll(".chat-send").forEach(el => {
    el.addEventListener("click", event => {
      event.preventDefault()
      const chatInput = document.querySelector(".chat-input")
      const message = chatInput.value
      const author = document.querySelector(".author-input").value
      pushMessage(channel, author, message)
      chatInput.value = ""
    })
  })

  channel.on("new_message", ({ author, message }) => {
    addMessage(author, message)
  })

  console.log("Joined channl:", res)
}

const connect = socket => {
  const enalbeLiveChat = document.getElementById("enable-chat-channel")
  if (!enalbeLiveChat) {
    return;
  }

  const chatroom = enalbeLiveChat.getAttribute("data-chatroom")
  const channel = socket.channel("chat:" + chatroom)

  channel.join()
    .receive("ok", res => onJoin(res, channel))
    .receive("error", res => console.log("Failed to join channel:", res))
}

export default { connect }