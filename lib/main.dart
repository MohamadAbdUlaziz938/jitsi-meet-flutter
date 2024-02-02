import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jitsi Meet Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: Locale("en"),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController joinLinkCtr;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    joinLinkCtr = TextEditingController();
  }

  void _joinMeet(
      {required String pathParams,
      required String? jwt,
      required String serverUrl}) async {
    var options = JitsiMeetingOptions(
      roomNameOrUrl: "$serverUrl$pathParams",
      // roomNameOrUrl: "https://meet.jit.si/Q-iGE3aiz_TGv0tB3syrt2",
      serverUrl: serverUrl,
      //serverUrl: "https://meet.jit.si",
      subject: "Jitsi Meet Test",

      /// if we add [isAudioOnly] true user can't see the shared camera by others default is false
      isAudioOnly: false,

      /// default to isVideoMuted false, this option doesn't mean to that button enable or disable share my camera
      /// it means disable my camera or enable it
      isVideoMuted: true,

      /// default to isAudioMuted false
      isAudioMuted: true,
      token: jwt,

      configOverrides: {
        // "lang": 'ar',
        // "defaultLanguage": "ar",

        "transcribeWithAppLanguage":false,
        "transcription.useAppLanguage":false,
        "preferredTranscribeLanguage":"en-US",
        "transcription.preferredLanguage": "en-US",
        "transcription": {
          "enabled": true,
          "useAppLanguage": false,
          "translationLanguagesHead": ["en"],
          "preferredLanguage": "en-US"
        }
      },
      featureFlags: {

        /// disable user to share screen
        "android.screensharing.enabled": false,
        /**
         * Flag indicating if Picture-in-Picture button should be shown while screen sharing.
         * Default: disabled (false).
         */

        "pip-while-screen-sharing.enabled": false,
        /**
         * Flag indicating if Picture-in-Picture should be enabled.
         * Default: auto-detected.
         */
        // "pip.enabled": true,

        /// disable user to share live stream from youtube
        "live-streaming.enabled": false,

        /// disable chat
        "chat.enabled": true,

        /// disable menu
        "overflow-menu.enabled": true,

        /// disable share my camera button, hide camera button which means to control my camera
        "video-mute.enabled": false,

        ///car mode
        "car-mode.enabled": false,

        /// invite friends
        "invite.enabled": false,

        /// availability to record the meet
        "recording.enabled": false,

        ///security-options password to the meet
        "security-options.enabled": false,

        /**
         * Flag indicating if the video share button should be enabled
         * Default: enabled (true).
         */
        "video-share.enabled": false,
        /**
         * Flag indicating if settings should be enabled.
         * Default: enabled (true).
         */
        "settings.enabled": false,

        "unsaferoomwarning.enabled": false
      },
    );

    await JitsiMeetWrapper.joinMeeting(
        options: options,
        listener: JitsiMeetingListener(
          onConferenceWillJoin: (url) {
            print("*** listener onConferenceWillJoin ***");
            print("url $url");
          },
          onConferenceJoined: (url) {
            print("*** listener onConferenceJoined ***");
            print("url $url");
          },
          onConferenceTerminated: (url, error) {
            print("*** listener onConferenceTerminated ***");
            print("url $url");
            print("error $error");
          },
          onClosed: () {
            print("*** listener onClosed ***");
          },
          onOpened: () {
            print("*** listener onOpened ***");
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Jitsi Meet Demo"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Join the meet',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: joinLinkCtr,
                      validator: (value) {
                        if (value?.startsWith("https://") == true) {
                          return null;
                        }
                        return "invalid link";
                      },
                      decoration: const InputDecoration(
                          hintText: "Paste meet link here",
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FilledButton(
                        onPressed: () {
                          unFocus(context);
                          final isValid =
                              ((formKey.currentState?..save())?.validate()) ??
                                  false;
                          if (isValid == true) {
                            Uri uri = Uri.parse(joinLinkCtr.text);
                            String? jwt = uri.queryParameters['jwt'];
                            String domain = "${uri.scheme}://${uri.host}";
                            print("jwt ${jwt}");
                            print("domain ${domain}");
                            print("params: ${uri.path}");

                            _joinMeet(
                                serverUrl: domain,
                                pathParams: uri.path,
                                jwt: jwt);
                          }
                        },
                        child: const Text("Join"))
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Dev: ", style: TextStyle(color: Colors.grey)),
              RichText(
                  text: const TextSpan(
                      text:
                          "Mohamad Abd-Ulaziz\nmohamad.samer.abdulaziz@gmail.com",
                      style: TextStyle(color: Colors.grey))),
              /*Column(
              children: [
                Text("Mohamad Abd-Ulaziz"),
                Text("mohamad.samer.abdulaziz@gmail.com"),
              ],
            )*/
            ],
          ),
        ],
      ),
    );
  }
}

void unFocus(BuildContext context) {
  final currentFocus = FocusManager.instance.primaryFocus;
  if (currentFocus?.hasPrimaryFocus == true) {
    currentFocus?.unfocus();
  }
}
