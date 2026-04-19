import 'package:flutter/material.dart';
import 'chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:const HomeScreen()
    );
  }
}
class HomeScreen extends StatelessWidget {
  const HomeScreen ({super.key});

  @override
  Widget build (BuildContext context){
    return  Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatPage(
                        myId: "user1",
                        receiverId: "user2",
                      ),
                    ),
                  );
                },
                child: const Text("Login as User 1"),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatPage(
                        myId: "user2",
                        receiverId: "user1",
                      ),
                    ),
                  );
                },
                child: const Text("Login as User 2"),
              ),
            ],
          ),
        ),
      );
  }
}