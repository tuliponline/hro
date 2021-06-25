getTimeStringNow() {
  var now = DateTime.now();
  String dateString = now.year.toString() +
      "/" +
      now.month.toString() +
      "/" +
      now.day.toString() +
      " " +
      now.hour.toString() +
      ':' +
      now.minute.toString();
  return dateString;

}

getTimeStampNow() {
  String dateString = DateTime.now().millisecondsSinceEpoch.toString();
  return dateString;
}
