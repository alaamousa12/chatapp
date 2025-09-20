import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news/constants.dart';
import 'package:news/models/message.dart';
import 'package:news/widgets/chat_bubble.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});
  static String id = 'ChatView';

  TextEditingController controller =
      TextEditingController(); // controller خذف القيمه الا داخل textField بعد الارسال
  final _controller = ScrollController();
  @override
  CollectionReference messages = FirebaseFirestore.instance.collection(
    kMessageCollections, // لو مش موجوده بينشئ referance على طول
  ); // لو موجوده بيجيب referance ليها
  Widget build(BuildContext context) {
    var email = ModalRoute.of(context)!.settings.arguments;
    return StreamBuilder<QuerySnapshot>(      // stream بتبنى الرساله فى وقتها
         // orderBy بيخزن البيانات بالترتيب عن طريق field createdAt
         // descending بيعكس الرساله بحيث يعرض اخر ساله اتبعتت
      stream: messages.orderBy(kCreatedAt, descending: true).snapshots(),    // request بستخدمه علشان يجيب البيانات الا محتاجها  
      builder: (context, snapshot) {  // snapshot الحاجه الا بتحتوى البيانات 
        if (snapshot.hasData) {    // شوف الاسناب شوت فيها بيانات ولا لا لو فيها بيانات اعرضها
          List<Message> messageList = [];      // الرسائل الا جايه عباره عن list of message
          for (int i = 0; i < snapshot.data!.docs.length; i++) {       // كل ما يعدى على document يخزنه على هيئة message على طول 
            messageList.add(Message.fromJson(snapshot.data!.docs[i]));    // هنخزنها فى فى messageList
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(image, height: 50),
                  Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,      // بتعكس list
                    controller: _controller,
                    itemCount: messageList.length,
                    itemBuilder: (context, index) {
                      return messageList[index].id == email     // لو بيساوى يبقا دا المستخدم الا بيبعت الرساله
                          ? ChatBubble(message: messageList[index])
                          : ChatBubbleForFriend(message: messageList[index]);   // لو مش بيساويها يبقا اميل الشخص التانى
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: controller,
                    onSubmitted: (value) {    // ناخد البيانات فى الحقل الا هى الرساله
                      messages.add({  
                        //kMessage: الرساله الا هتنضاف فى fireStore
                        kMessages: value,
                        kCreatedAt: DateTime.now(),      // بضيف الوقت الا هتتعرض فيه الرساله علشان اظهر الرسالئل بالترتيب
                        'id': email,     // arguments
                      });
                      controller
                          .clear(); // controller خذف القيمه الا داخل textField بعد الارسال
                      _controller.animateTo(
                        0, // بيعمل اسكرول لاخر رساله اتبعتت الا هى اخر حته الا عاوز اروح عليها
                        curve: Curves
                            .easeOut, // الشكل الا هيتحرك بيه مثلا يتحرك بسرعه فى الاول و فى الاخر يتحرك ببطء
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.send, color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                      hintText: 'Send Message',
                      hintStyle: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {  // لو لا اعرض الرساله دى 
          return Center(child: Text('Loading...'));
        }
      },
    );
  }
}
