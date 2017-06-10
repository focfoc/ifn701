<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
response.setHeader("Pragma","no-cache"); //HTTP 1.0
response.setDateHeader ("Expires", 0);
//prevents caching at the proxy server
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="http://code.jquery.com/jquery-latest.min.js"></script>
<script type="text/javascript" src="recorder.js"> </script>
<script src="https://code.responsivevoice.org/responsivevoice.js"></script>
<title>Search demo</title>
<style>
img {
  vertical-align: top;
  max-height: 1.4em;
  max-width: 1.4em;
}
#outer {
  display: table;
  position: absolute;
  height: 100%;
  width: 100%;
}
#middle {
    display: table-cell;
    padding-top: 100px;
}
#inner {
    margin-left: auto;
    margin-right: auto; 
    width: 1000px;
}
#middleArea {
   display: table;
}
#resultArea {
   display: table;
}
#responseArea {
	display: table-cell;
	vertical-align: middle;
	padding-left: 20px;
}
#recordButtonArea {
	display: table-cell;
	vertical-align: middle;
}
#audioArea {
	padding-left: 20px;
	display: table-cell;
	vertical-align: middle;
}
#response {
  width: 500px;
  padding: 10px 10px;
  border: 1px solid #b7b7b7;
  font: normal 20px/normal "Times New Roman", Times, serif;
  color: #000000;
  line-height: 1.4em;
  -webkit-appearance: textfield;
  appearance: textfield
}
#alternativeArea {
	display: table-cell;
	vertical-align: middle;
}
#playButtonArea {
	display: table-cell;
	padding-left: 10px;
	vertical-align: middle;
}
 #mynetwork {
   width: 600px;
   height: 400px;
   border: 1px solid lightgray;
 }
  #playButton{
	display: none;
 }
.alternative {
 border: 0 !important;  /*REMOVES BORDER*/
 color: #ffffff;
 -webkit-border-radius: 5px;
 border-radius: 5px;
 font-size: 25px;
 padding: 10px;
 text-align: center;
 margin-right: 10px;
}
.alternative1 {
-webkit-appearance: none;
 border: 0 !important;  /*REMOVES BORDER*/
 color: #ffffff;
 -webkit-border-radius: 5px;
 border-radius: 5px;
 font-size: 25px;
 padding: 10px;
 text-align: center;
 margin-right: 10px;
}
.recorder{
    height: 100px;
    width: 100px;
}
.player{
    height: 40px;
    width: 40px;
}
</style>
</head>
<body>
	<!-- <form action="SearchServlet" method="POST"> -->
<!-- 		<input type="text" name="query"> <input type="submit" value="Search"> -->
 		<select id="demo" onchange="LoadDemo(this)">
 			<option selected disabled>Select Demo</option>
 			<option value="demo1" label="Demo 1"/>
 			<option value="demo2" label="Demo 2"/>
 			<option value="demo3" label="Demo 3"/>
 		</select>
 		<input id="demoButton" type="button" value="Demo" onclick="Demo(this)">
	<div id="outer">
		<div id="middle">
			<div id="inner">
			    <div id="middleArea">
			    	<div id="recordButtonArea">
			   			<input onclick="startRecording()" type="image" value="Record" class="recorder" src="images/icons/recorder.png" id="recordButton"/>
			<!--    		<input onclick="search()" disabled="true" type=button value="Search" class="recorder"/> -->
				   	</div>
				   	<div id="responseArea">
				   		<!-- <input id="response" /> -->
				   		<div id="response" contenteditable="true"> </div>
				   	</div>
				   	<div id="audioArea">
						<audio controls></audio>
					</div>
			   	</div>
			   	<div id="resultArea">
				   	<div id="alternativeArea">
						<div id="alternative"></div> 
					</div>
					<div id="playButtonArea">
						<input id="playButton" onclick="ClickPlay()" type="image" value="Play" class="player" src="images/icons/play.png"/>
					</div>
				</div>
			<!-- 	<div id="mynetwork"></div> -->
			</div>
		</div>
	</div>     		
<!-- 	</form>  -->                     
 	<script>
		var audio_context;
		var recorder;
		var input;
		var audio = document.querySelector('audio');
		var response = document.getElementById('response');
		var alternative = document.getElementById('alternative');
		var recordButton = document.getElementById('recordButton');
		var playButton = document.getElementById('playButton');
		var lastIndex;
		var colors;
		var emoj;
		var hypothesis;
		var pureText;
		var nodes = [];
		var edges = [];
		
		function ClickPlay(){
			responsiveVoice.speak(pureText);
		}
		
		function startUserMedia(stream) {
			input = audio_context.createMediaStreamSource(stream);
			console.log('Media stream created.');
		}
		
		function LoadDemo(e){
			var demo = "demos/" + e.options[e.selectedIndex].value + ".wav";
			audio.src = demo;
		}
		
		function Demo(e){
			e.disabled = true;
			alternative.innerHTML = "";
			playButton.style.display = 'none';
			response.innerHTML = "";
			var select = document.getElementById('demo');
			var demo = select.options[select.selectedIndex].value;
			recorder = new Recorder(input);
			recorder && recorder.record();				
 			recorder && recorder.stop();
 			recorder && recorder.exportWAV(function(blob) {
 			var url = URL.createObjectURL(blob);
 			var xhr = new XMLHttpRequest();
 			xhr.open('POST', 'SearchServlet?demo='+demo, true);
 			xhr.onload = function(e) {
 				console.log("loaded");
 			};
 			xhr.onreadystatechange = function() {
 			if (xhr.readyState == 4) {
 	 			e.disabled = false;
 				colors=['#59d659','#8fd659','#aad659','#bfd659','#d6c959','#d6b259','#d69f59','#d68b59','#d68b59','#d67859','#d65959'];
 				emoj=['call','car','cat','egg','hate','house','one','pay','power','rice','taxi','ten','wagon','weapon','weather','web','what','wound','zero'];
 				lastIndex = -1;
 				ClearAllSelect();
 				var data = xhr.responseText;
 	 			var splits = data.split('~');
 	 			console.log(data);
 	 			hypothesis = (splits[0]);
 				alternative.innerHTML = 'Or do you mean:  ';
 				SetFirstNode(splits[1],0);
 				SetDefault();
 				}
 			};
 					// Listen to the upload progress.
 			xhr.upload.onprogress = function() {
 				console.log("uploading...");
 				};
 			xhr.setRequestHeader("Content-Type", "text");
 			xhr.send(demo);
 			});
		}

		function startRecording() {
			alternative.innerHTML = "";
			playButton.style.display = 'none';
			response.innerHTML = "";
			recordButton.disabled = true;
			recordButton.src = 'images/icons/recording.png';
			recorder = new Recorder(input);
			console.log('Recorder initialised.');
			recorder && recorder.record();
			console.log('Recording...');
 			setTimeout(function() { 				
 				recorder && recorder.stop();
 				console.log('Stopped recording.');
 				recorder && recorder.exportWAV(function(blob) {
 					var url = URL.createObjectURL(blob);
 					audio.src = url;
 					var xhr = new XMLHttpRequest();
 					xhr.open('POST', 'SearchServlet', true);
 					xhr.onload = function(e) {
 						console.log("loaded");
 					};
 					xhr.onreadystatechange = function() {
 						console.log("state: " + xhr.readyState);
 				        if (xhr.readyState == 4) {
 				        	colors=['#59d659','#8fd659','#aad659','#bfd659','#d6c959','#d6b259','#d69f59','#d68b59','#d68b59','#d67859','#d65959'];
 				        	emoj=['call','car','egg','house','one','pay','rice','taxi','weather','what','zero'];
 				        	lastIndex = -1;
 				        	ClearAllSelect();
 				            var data = xhr.responseText;
 	 			            var splits = data.split('~');
 	 						console.log(data);
 	 						hypothesis = (splits[0]);
 				            alternative.innerHTML = 'Or do you mean:  ';
 				            SetFirstNode(splits[1],0);
// 				            SetAlternative(splits[1],1);
 				            SetDefault();
 				        }
 					};
 					// Listen to the upload progress.
 					xhr.upload.onprogress = function() {
 						console.log("uploading...");
 					};
 					xhr.setRequestHeader("Content-Type", "audio/wav");
 					xhr.send(blob);
 				});
 				recordButton.src = 'images/icons/recorder.png';
 				recordButton.disabled = false;
			}, 3000); 
		}

		function ClearAllSelect(){
			while(alternative.firstChild){
				alternative.removeChild(alternative.firstChild);
			}
		}
		
		function SetDefault()
		{
			var i = 0;
			var select = document.getElementById('select'+i);
			var options = select.options
			for(j = 0; j <= options.length; j++){
				if(options[j].text.length > 0 && hypothesis.indexOf(options[j].text) != -1){
					options[j].selected = 'selected';
					console.log("word: " + options[j].text);
					break;
				}
			}
			select.onchange();						
		}
		
		function RemoveDropDownList(index)
		{
			var temp = 0
			response.innerHTML = "";
			pureText = "";
			for(i = 0; i <= index; i++){
				var select = document.getElementById('select'+i);
				var text = select.options[select.selectedIndex].text;
				if(response.innerHTML.length > 0)
					response.innerHTML += " ";
				response.innerHTML += text;
				pureText += text + " ";
				if(emoj.indexOf(text) != -1)
					response.innerHTML += "<img src=\"images/icons/" + text + ".png\"/> ";
			}
			for(i = index + 1; i <= lastIndex; i++){
				var select = document.getElementById('select'+i);
				select.parentNode.removeChild(select);
				temp++;
			}
			lastIndex -= temp;
		}
		
/* 		function ExistNode(word){
			for(i = 0; i < nodes.length; i++){
				var node = nodes[i];
				if(word == node.id)
					return true;
			}
			return false;
		}
		
		function ExistEdge(from,to){
			for(i = 0; i < edges.length; i++){
				var edge = edges[i];
				if(from == edge.from && to == edge.to)
					return true;
			}
			return false;
		} */
		
		function SetFirstNode(json){
	        var jsonObj = JSON.parse(json);
	        var word = jsonObj.Word;
	        if(word != ""){
		        var select = document.createElement("select");
		        select.setAttribute("id", "select0");
				var opt = document.createElement("option");
				select.setAttribute("class","alternative1");
				opt.setAttribute("style", "background: " + colors[0]);
				select.setAttribute("style", "background: " + colors[0]);
				opt.text = word;
				if (jsonObj.hasOwnProperty('Node')) {
					var node = jsonObj.Node;
					opt.value = JSON.stringify(node);
					select.onchange = function(){
						RemoveDropDownList(0);
						SetAlternative(this.value,1);
						var selectedOpt = this.options[this.selectedIndex];
						this.setAttribute("style", "background: " + selectedOpt.style.background);
					};
				}
				if(hypothesis.indexOf(opt.text) != -1){
					opt.selected = 'selected';
				}
				response.innerHTML += opt.text;
				if(emoj.indexOf(opt.text) != -1)
					response.innerHTML += "<img src=\"images/icons/" + opt.text + ".png\"/> ";
				pureText += opt.text;
				if (!jsonObj.hasOwnProperty('Node')) {
					playButton.setAttribute("style","display:block");
				}					
				select.options.add(opt);
				alternative.appendChild(select);
				++lastIndex;
				if (jsonObj.hasOwnProperty('Node')) {
					select.onchange();
				}
	        }
	        else{
	        	SetAlternative(json,0)
	        }
		}

		function SetAlternative(json,current) {
	        var jsonObj = JSON.parse(json);
			if (jsonObj.hasOwnProperty('Node')) {
				var next = jsonObj.Node;
		        var select = document.createElement("select");
		        select.setAttribute("id", "select" + (current));
				if (Array.isArray(next)) {		
			        select.setAttribute("class", "alternative");
			        var gotMatchWord = false;
					for (i = 0; i < next.length && i < colors.length; i++) {
						var opt = document.createElement("option");
						opt.setAttribute("style", "background: " + colors[i]);
						opt.text = next[i].Word;
						if (next[i].hasOwnProperty('Node')) {
							opt.value = JSON.stringify(next[i]);
						}
						if(!gotMatchWord && hypothesis.indexOf(opt.text) != -1){
							opt.selected = 'selected';
							gotMatchWord = true;
						}
						if (!next[i].hasOwnProperty('Node')) {
							response.innerHTML += " " + opt.text;
							pureText += opt.text;
							playButton.setAttribute("style","display:block");
						}	
						select.options.add(opt);
					}
					select.onchange = function(){
						RemoveDropDownList(current);
						SetAlternative(this.value,current+1);
						var selectedOpt = this.options[this.selectedIndex];
						this.setAttribute("style", "background: " + selectedOpt.style.background);
					};
					++lastIndex;
					alternative.appendChild(select);
					select.onchange();
				}
	 			else{
					var opt = document.createElement("option");
					select.setAttribute("class","alternative1");
					opt.setAttribute("style", "background: " + colors[0]);
					select.setAttribute("style", "background: " + colors[0]);
					opt.text = next.Word;
					if (next.hasOwnProperty('Node')) {
						opt.value = JSON.stringify(next);
						select.onchange = function(){
							RemoveDropDownList(current);
							SetAlternative(this.value,current+1);
							var selectedOpt = this.options[this.selectedIndex];
							this.setAttribute("style", "background: " + selectedOpt.style.background);
						};
					}
					if(hypothesis.indexOf(opt.text) != -1){
						opt.selected = 'selected';
					}
					response.innerHTML += " " + opt.text;
					pureText += opt.text;
					if (!next.hasOwnProperty('Node')) {
						playButton.setAttribute("style","display:block");
					}					
					select.options.add(opt);
					alternative.appendChild(select);
					++lastIndex;
					if (next.hasOwnProperty('Node')) {
						select.onchange();
					}
				} 
			}
		}

		window.onload = function init() {
			try {
				// webkit shim
				window.AudioContext = window.AudioContext
						|| window.webkitAudioContext;
				navigator.getUserMedia = navigator.getUserMedia
						|| navigator.webkitGetUserMedia
						|| navigator.mozGetUserMedia
						|| navigator.msGetUserMedia;
				window.URL = window.URL || window.webkitURL;

				audio_context = new AudioContext;
				console.log('Audio context set up.');
				console.log('navigator.getUserMedia '
						+ (navigator.getUserMedia ? 'available.'
								: 'not present!'));
			} catch (e) {
				console.log('No web audio support in this browser!');
			}

			navigator.getUserMedia({
				audio : true
			}, startUserMedia, function(e) {
				console.log('No live audio input: ' + e);
			});
		};
			
		</script>

</body>
</html>