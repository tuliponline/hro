

Future<String> getStatusString(String status)async{
  String string;
  switch (status) {
    case '0':
      {
        string =  'ยกเลิก';
      }
      break;
    case '1':
      {
        string = 'รับOrder';
      }
      break;
    case '2':
      {
        string =  'รอร้านค้าตอบรับ';
      }
      break;
    case '3':
      {
        string = 'ร้านค้ากำลังเตรียมสินค้า';
      }
      break;
    case '4':
      {
        string = 'กำลังออกจัดส่ง';
      }
      break;
    case '5':
      {
        string = 'จัดส่งสำเร็จ';
      }
      break;
    case '6':
      {
        string = 'จัดส่งไม่สำเร็จ';
      }
      break;

    case '9':
      {
        string = 'รอพนักงานส่งตอบรับ';
      }
  }
  return string;
}

Future<String>getSetStatusBy(String setBy)async{
  String setBy = '123456';
  // switch(setBy){
  //   case 'user' : {
  //     setBy =  'ลูกค้า';
  //   }
  //   break;
  //   case 'shop' : {
  //     setBy = 'ร้านค้า';
  //   }
  //   break;
  //   case 'driver' : {
  //     setBy = 'พนักงานส่ง';
  //   }
  //   break;
  // }
  return setBy;
}



