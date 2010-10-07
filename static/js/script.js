/* Author: Eric Koslow

*/

$(document).ready(function() {
   // do stuff when DOM is ready
   $("footer").hide();
   $("#main > a").click(function() {
     $('footer').show('slow');
     return false;
     });
 });
