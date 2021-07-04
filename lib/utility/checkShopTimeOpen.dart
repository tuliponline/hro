


Future<bool> checkShopTimeOpen(String shopTime)  async{
  print ("shopTime= " + shopTime );
   bool shopOpen = false;
  var now = DateTime.now();
  int dayNum = now.weekday;
  List<String> statusTimeAll = shopTime.split(",");
  for (int i = 0; i < statusTimeAll.length - 1; i++) {
    if (dayNum == i + 1) {
      List<String> statusTime = statusTimeAll[i].split("/");
      if (statusTime[0] == "close") {
        shopOpen = false;
      } else {
        List<String> openClose = statusTime[1].split('-');
        List<String> openHM = openClose[0].split(':');
        List<String> closeHM = openClose[1].split(':');
        final startTime = DateTime(now.year, now.month, now.day,
            int.parse(openHM[0]), int.parse(openHM[1]));
        final endTime = DateTime(now.year, now.month, now.day,
            int.parse(closeHM[0]), int.parse(closeHM[1]));
        final currentTime = DateTime.now();
        (currentTime.isAfter(startTime) && currentTime.isBefore(endTime))
            ? shopOpen = true
            : shopOpen = false;
      }
    }

  }
  return shopOpen;
}