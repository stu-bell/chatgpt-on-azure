window.htmx = require("htmx.org"); // https://htmx.org/events
import showdown  from 'showdown';
import DOMPurify from 'dompurify';
import downloadFile from './downloadFile'

const sdConverter = new showdown.Converter()

// modifyResponse modifies the server response content before htmx swapping
// element.addEventListener("htmx:beforeSwap", modifyResponse(s => s.toUpperCase()))
const modifyResponse = (fn) => (event) =>
  (event.detail.serverResponse = fn(event.detail.serverResponse));

// serializeToString for stringifying HTML fragments
const serializeToString = (fragment) => (new XMLSerializer()).serializeToString(fragment)

// show a message popup for a number of seconds
const showSnackBarMessage = (msg, dur=2000) => {
  const el = htmx.find('#snackbar');
  el.textContent = msg;
  el.classList.add('show');
  setTimeout(() => el.classList.remove('show'), dur);
}

// Global 
document.addEventListener("htmx:sendError", function (event) {
  showSnackBarMessage("There was a connection problem. Please check your internet connection and retry.");
});

// redirect if any request is unauthorized. API will not respond
document.addEventListener("htmx:responseError", function (event) {
 if(event.detail.xhr.status === 401){ 
  window.location.replace("/unauthorized");
 }
});

// Message Form
// focusMessageInput applies focus to message input and sets placeholder
const focusMessageInput = () => {
  const elm = htmx.find("#messageInput");
  elm.focus();
  elm.placeholder = 'Press shift-enter for multi line';
};

// add message prompt to chatbox
htmx.find("#messageForm").addEventListener(
  "htmx:trigger",
  (event) => {
    // HTMX sends backend request
    const userMsg = DOMPurify.sanitize(htmx.find("#messageInput").value);
    const msgNode = htmx.find("#msg-user").content.cloneNode(true);
    // add message content to chat 
    htmx.find(msgNode, ".text").innerHTML = userMsg.replace(/\n/g, '<br/>'); 
    // add text as data attribute
    htmx.find(msgNode, '.message').setAttribute('data-content', userMsg);
    htmx.find('#chatbox').appendChild(msgNode);
  }
);

// get text from all messages in the chat
const getMessageHistory = () => {
    // build array of all messages in the chat. Would it be better to read these from the backend (if available)?
    const messageHistory = Array.from(htmx.findAll('#chatbox .message')).map(
      el => ({
        role: el.getAttribute('data-role'),
        content: el.getAttribute('data-content'),
      })
    );
    // currently the usage notes are formatted as a message - remove this one
    messageHistory.shift();
    return messageHistory;  
}

// modify request to sendMessage api
htmx.find("#messageForm").addEventListener(
  "htmx:configRequest",
  (event) => {
    // send the entire message history as the message parameter
    event.detail.parameters.messageHistory = JSON.stringify(getMessageHistory());
  }
);

// format api response in message chat
htmx.find("#chatbox").addEventListener(
  "htmx:beforeSwap",
  // complete the response template and return the result for swapping
  modifyResponse((res) => {
    const messageBubble = htmx.find("#msg-system").content.cloneNode(true);
    htmx.find(messageBubble, ".text").innerHTML = DOMPurify.sanitize(sdConverter.makeHtml(res)); 
    // add original response text as data attribute
    htmx.find(messageBubble, '.message').setAttribute('data-content', DOMPurify.sanitize(res));
    return serializeToString(messageBubble);
  })
);

// scrollLastIntoView scrolls a container so its last element is in view
const scrollLastIntoView = (containerElement) => {
  const lastElement = containerElement.children[containerElement.children.length - 1]
  lastElement.scrollIntoView({ behavior: "smooth", block: "start" });
}

// afterswap scroll the response into view
htmx.find("#chatbox").addEventListener(
  "htmx:afterSwap",
  (event) => scrollLastIntoView(event.target)
);

// tidy up after sending request
htmx.find("#messageForm").addEventListener(
  "htmx:beforeRequest",
  (event) => {
    // clear message input
    htmx.find('#messageInput').value = "";
    focusMessageInput();
    scrollLastIntoView(htmx.find('#chatbox'));
  },
  false
);

// show error messages
htmx.find("#messageForm").addEventListener("htmx:responseError", (event) => {
  const errorMsg = event.detail.xhr.response || '';
  showSnackBarMessage("Something went wrong, please try again.\n" + errorMsg);
});

// focus events
htmx.find("#messageInput").addEventListener("focusout", (event) => {
  event.target.placeholder = "press / or \\ to start typing";
});

// keyboard shortcuts
htmx.find("#messageInput").addEventListener("keyup", (event) => {
  // enter (without shift) submits the form
  if (event.which === 13 && !event.shiftKey) {
    event.preventDefault();
    htmx.trigger('#messageForm', 'submit');
  }
});
document.addEventListener("keydown", function (event) {
  // slash - focus on message input (unless we're already focussed on an input)
  if (
    (event.key === "/" || event.key === "\\") &&
    event.target.tagName.toLowerCase() !== "textarea"
  ) {
    event.preventDefault();
    focusMessageInput();
  }
});


// Toolbar
htmx.find('#exportTxt').addEventListener('click', (event)=>{
  const messageHistory = getMessageHistory().map(
    x => `[${x.role}]:\n${x.content}${x.role==='user'?'\n':'\n\n'}`
  ).join('');
  downloadFile(messageHistory, 'Chat.txt');
});
htmx.find('#exportPdf').addEventListener('click', (event)=>{
  window.print();
});


htmx.find('#clearChat').addEventListener('click', (event)=>window.location.reload());;