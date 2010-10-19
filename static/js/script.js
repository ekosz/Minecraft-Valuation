/* Author: Eric Koslow

*/

$(document).ready(function() {
   // do stuff when DOM is ready
   $("#info").hide();
   $("#main > a").click(function() {
     if($('#info').is(":hidden")) {
       $('#info').slideDown('slow');
       return false;
     } else {
       $("#info").hide();
     }
   });
   
 });
