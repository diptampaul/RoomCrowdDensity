import 'package:flutter/material.dart';

class FlashMessageScreen extends StatefulWidget {
  const FlashMessageScreen({Key? key}) : super(key: key);

  @override
  State<FlashMessageScreen> createState() => _FlashMessageScreenState();
}

class _FlashMessageScreenState extends State<FlashMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Container(
                    padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                    height: 90.0,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      color: Colors.redAccent,
                    ),
                  child: Column(
                      children: const [
                        Text(
                          "Oh Snap !",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Show default Error message",
                         style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              )
            );
          },
          child: Text("Show Error message"),
        ),
      ),
    );
  }
}




class ShowErrorScreen extends StatelessWidget {
  const ShowErrorScreen({super.key, Key? required, required this.errorText });
  final String errorText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SnackBar(
        content: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
          height: 90.0,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
            color: Colors.redAccent,
          ),
          child: Column(
              children: [
                Text(
                  "Oh Snap !",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  errorText,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
    );
  }
}

