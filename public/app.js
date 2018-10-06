function isChrome() {
  var isChromium = window.chrome,
    winNav = window.navigator,
    vendorName = winNav.vendor,
    isOpera = winNav.userAgent.indexOf("OPR") > -1,
    isIEedge = winNav.userAgent.indexOf("Edge") > -1,
    isIOSChrome = winNav.userAgent.match("CriOS");

  if(isIOSChrome){
    return true;
  } else if(isChromium !== null && isChromium !== undefined && vendorName === "Google Inc." && isOpera == false && isIEedge == false) {
    return true;
  } else {
    return false;
  }
}

function gotoListeningState() {
  const micListening = document.querySelector(".mic .listening");
  const micReady = document.querySelector(".mic .ready");

  micListening.style.display = "block";
  micReady.style.display = "none";
}

function gotoReadyState() {
  const micListening = document.querySelector(".mic .listening");
  const micReady = document.querySelector(".mic .ready");

  micListening.style.display = "none";
  micReady.style.display = "block";
}

function addBotItem(text) {
  const appContent = document.querySelector(".app-content");
  appContent.innerHTML += '<div class="item-container item-container-bot"><div class="item"><p>' + text + '</p></div></div>';
  appContent.scrollTop = appContent.scrollHeight; // scroll to bottom
}

function addUserItem(text) {
  const appContent = document.querySelector(".app-content");
  appContent.innerHTML += '<div class="item-container item-container-user"><div class="item"><p>' + text + '</p></div></div>';
  appContent.scrollTop = appContent.scrollHeight; // scroll to bottom
}

function displayCurrentTime() {
  const timeContent = document.querySelector(".time-indicator-content");
  const d = new Date();
  const s = d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
  timeContent.innerHTML = s;
}

function addError(text) {
  addBotItem(text);
  const footer = document.querySelector(".app-footer");
  footer.style.display = "none";
}

document.addEventListener("DOMContentLoaded", function(event) {


  // test for relevant API-s
  // for (let api of ['speechSynthesis', 'webkitSpeechSynthesis', 'speechRecognition', 'webkitSpeechRecognition']) {
  //   console.log('api ' + api + " and if browser has it: " + (api in window));
  // }

  displayCurrentTime();

  // check for Chrome
  if (!isChrome()) {
    addError("This demo only works in Google Chrome.");
    return;
  }

  if (!('speechSynthesis' in window)) {
    addError("Your browser doesn’t support speech synthesis. This demo won’t work.");
    return;
  }

  if (!('webkitSpeechRecognition' in window)) {
    addError("Your browser cannot record voice. This demo won’t work.");
    return;
  }

  // Now we’ve established that the browser is Chrome with proper speech API-s.

  // api.ai client
  const apiClient = new ApiAi.ApiAiClient({accessToken: '04ebac24d144426fb2b26b71455f9175'});

  // Initial feedback message.
  addBotItem("Hi! I’m voicebot. Tap the microphone and start talking to me.");

  var recognition = new webkitSpeechRecognition();
  var recognizedText = null;
  recognition.continuous = false;
  recognition.onstart = function() {
    // alert("here in onstart");
    // document.getElementById("p1").innerHTML = "Order Started!";
    recognizedText = null;
  };
  recognition.onresult = function(ev) {
    recognizedText = ev["results"][0][0]["transcript"];
    addUserItem(recognizedText);
    ga('send', 'event', 'Message', 'add', 'user');

    let promise = apiClient.textRequest(recognizedText);

    promise
        .then(handleResponse)
        .catch(handleError);

    function handleResponse(serverResponse) {
      // Set a timer just in case. so if there was an error speaking or whatever, there will at least be a prompt to continue
      var timer = window.setTimeout(function() { startListening(); }, 20000);

      const speech = serverResponse["result"]["fulfillment"]["speech"];
      var msg = new SpeechSynthesisUtterance(speech);
      addBotItem(speech);
      console.log("lelzzzz");
      var orders_array = jQuery.cookie("orders").split('&');
      // console.log(orders_array);
      console.log(serverResponse);
      console.log("raza hussain");
      console.log(serverResponse["result"]["action"]);
      if(serverResponse["result"]["action"]=="Checkout") {
        window.location.href = "/maps_test";
      }else if(serverResponse["result"]["action"]=="ShowRestaurant") {
        window.location.href = "/nearby_business";
      }
      var all_items = ["donut","coffee"];
      var all_prices = [1.5,2];
      var default_price = 3;
      var tax_rate = 0.10;
      var action = serverResponse["result"]["action"];
      var total_cost = parseInt(jQuery.cookie("total_cost"));
      if(isNaN(total_cost)) {
        total_cost = 0;
      }
      //------------------------------------------------------------
        // console.log("inside drinks");
        // console.log(serverResponse["result"]["action"]);
        // if( serverResponse["result"]["action"]=="OrderDrink" ) {

        //   document.getElementById("p1").innerHTML += "Extra Flavor"+" : $"+1.5+"<br>";
        // }



      //------------------------------------------------------------
      
      if(serverResponse["result"]["action"]=="magic") {
      } else if(serverResponse["result"]["action"]=="magic_pay.verification") {
        window.location.href = "/magic";
      }
      if(serverResponse["result"]["action"]=="coffee.add_flavor") {
        if(serverResponse["result"]["resolvedQuery"]=="yes") {
          document.getElementById("p1").innerHTML += "Extra Flavor"+" : $"+1.5+"<br>";
          total_cost = total_cost + 1.5;
          document.getElementById("p2").innerHTML = " TOTAL COST: $"+total_cost+"<br>";
        }
      } else if(serverResponse["result"]["action"]=="ordercoffee.add_sugar") {
        if(serverResponse["result"]["resolvedQuery"]=="yes") {
          document.getElementById("p1").innerHTML += "Sugar"+" : $"+0.5+"<br>";
          total_cost = total_cost + 0.5;
          document.getElementById("p2").innerHTML = " TOTAL COST: $"+total_cost+"<br>";
        }
        document.getElementById("img1").src="/images/coffee_flavors.jpg";
      } else if(serverResponse["result"]["action"]=="ordercoffee.ordercoffee-no") {
        document.getElementById("img1").src="/images/coffee_flavors.jpg";
      } else if( serverResponse["result"]["action"]=="coffee.add_item" ) {
        var size = serverResponse["result"]["parameters"]["size"];
        if(size!="") {
          var amount = serverResponse["result"]["parameters"]["number"];
          if(isNaN(amount)==true) {
            amount = 1;
          }
          var cost = 2;
          if(size=="medium") {
            cost = 4;
          }else if(size=="large") {
            cost = 5;
          }
          total_cost = total_cost + cost;
          document.getElementById("p1").innerHTML += amount+" "+size+" "+"Coffee"+" : $"+cost+"<br>";
          document.getElementById("p2").innerHTML = " TOTAL COST: $"+total_cost+"<br>";
          document.getElementById("img1").src="/images/sugar.jpeg";
          // document.getElementById("img1").src="/images/hot-drinks.jpg";
        }else{
          document.getElementById("img1").src="/images/coffee_sizes.jpg";
        }
      } else if(action=="orderdonut.show_types") {
        document.getElementById("img1").src="/images/dunkin-donut.jpg";
      } else if(action == "add_item") {
        var donut_types = serverResponse["result"]["parameters"]["donutType"];
        var donut_numbers = serverResponse["result"]["parameters"]["number"];
        if(donut_types.length!=0) {
          for(i=0; i<donut_types.length; i++) {
            var donut_type = donut_types[i];
            var donut_count;
            if(i<donut_numbers.length) {
              donut_count = donut_numbers[i];
              orders_array.push(donut_type);
              orders_array.push(donut_count);
              var cost = default_price*donut_count;
              if(donut_type.includes("donut")) {
                cost = all_prices[0]*donut_count;
              }else if(donut_type.includes("coffee")) {
                cost = all_prices[1]*donut_count;
              }
              console.log(total_cost);
              total_cost = total_cost + cost;
              document.getElementById("p1").innerHTML += donut_count+" "+donut_type+" : $"+cost+"<br>";
              document.getElementById("p2").innerHTML = " TOTAL COST: $"+total_cost+"<br>";
            }
          }
          
          $.cookie("orders", orders_array);
        }
      } else if(action=="confirm_order") {
        var msg1 = new SpeechSynthesisUtterance("Perfect. You are now redirected to the payments page.");
        window.speechSynthesis.speak(msg1);
        window.location.href = "/creditpayment";
      }
      $.cookie("total_cost", total_cost);
      // if( speech.startsWith("Showing you different types of donuts") ) {
      //   document.getElementById("img1").src="/images/dunkin-donut.jpg";
      // } else if( speech.startsWith("Showing you different types of hot drinks") ) {
      //   document.getElementById("img1").src="/images/hot-drinks.jpg";
      // } else if( speech.includes("donut confirmed") ) {
      //   document.getElementById("p1").innerHTML += "1 donut : $2<br>"
      // }
      ga('send', 'event', 'Message', 'add', 'bot');
      msg.addEventListener("end", function(ev) {
        window.clearTimeout(timer);
        startListening();
      });
      msg.addEventListener("error", function(ev) {
        window.clearTimeout(timer);
        startListening();
      });

      window.speechSynthesis.speak(msg);
    }
    function handleError(serverError) {
      console.log("Error from api.ai server: ", serverError);
    }
  };

  recognition.onerror = function(ev) {
    console.log("Speech recognition error", ev);
  };
  recognition.onend = function() {
    gotoReadyState();
    // document.getElementById("p1").innerHTML = "Order Ended!";
  };

  function startListening() {
    gotoListeningState();
    recognition.start();
  }

  const startButton = document.querySelector("#start");
  startButton.addEventListener("click", function(ev) {
    ga('send', 'event', 'Button', 'click');
    startListening();
    ev.preventDefault();
  });

  // Esc key handler - cancel listening if pressed
  // http://stackoverflow.com/questions/3369593/how-to-detect-escape-key-press-with-javascript-or-jquery
  document.addEventListener("keydown", function(evt) {
    evt = evt || window.event;
    var isEscape = false;
    if ("key" in evt) {
        isEscape = (evt.key == "Escape" || evt.key == "Esc");
    } else {
        isEscape = (evt.keyCode == 27);
    }
    if (isEscape) {
        recognition.abort();
    }
  });
});
