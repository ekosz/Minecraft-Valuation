/* Author: Eric Koslow

*/

$(document).ready(function() {
   // do stuff when DOM is ready
   $("#info").hide();
   $("#main > a").click(function() {
     $('#info').slideDown('slow');
     return false;
     });
 });
