import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Material App",
      home: WidgetApp(),
    );
  }
}

class WidgetApp extends StatefulWidget {
  @override
  _WidgetExampleState createState() {
    return _WidgetExampleState();
  }
}

class _WidgetExampleState extends State<WidgetApp> {
  TextEditingController controller = TextEditingController(); //원문 입력창 컨트롤러
  late OnDeviceTranslator onDeviceTranslator; //MLKit 번역기
  final modelManager = OnDeviceTranslatorModelManager(); //언어 모델 관리
  String translatedText = ""; // 번역된 텍스트
  TranslateLanguage _sourceLanguage = TranslateLanguage.english; //원문 언어 초기값
  TranslateLanguage _targetLanguage = TranslateLanguage.korean; //타겟 언어 초기값

  @override
  void initState() { //처음 앱 시작할때
    super.initState();
    onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.korean,
    );

    // 텍스트 입력창의 변화를 감지하여 번역을 수행
    controller.addListener(_translate);
  }

  @override
  void dispose() {
    onDeviceTranslator.close();
    controller.dispose();
    super.dispose();
  }

  void _switchLanguages() { //언어 스위칭 버튼의 함수
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );
    });
    _translate();
  }

  void _modelDownload() async { //언어 모델 자동 다운로드
    final bool issourceModelDownloaded = await modelManager.isModelDownloaded(_sourceLanguage.bcpCode);
    final bool istargetModelDownloaded = await modelManager.isModelDownloaded(_targetLanguage.bcpCode);

    if (!issourceModelDownloaded) {
      await modelManager.downloadModel(_sourceLanguage.bcpCode);
    }

    if (!istargetModelDownloaded) {
      await modelManager.downloadModel(_targetLanguage.bcpCode);
    }
  }

  void _translate() async { // 번역 기능 함수
    final text = controller.text;
    _modelDownload();
    if (text.isNotEmpty) {
      final translation = await onDeviceTranslator.translateText(text);
      setState(() {
        translatedText = translation;
      });
    } else {
      setState(() {
        translatedText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Material App"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextField( // 원문 입력창
                    keyboardType: TextInputType.text,
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "번역할 문장 입력",
                    ),
                  ),
                ),
                flex: 2,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text( // 번역된 텍스트
                    translatedText,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                flex: 2,
              ),
              Flexible(
                child: Row( // 언어 선택 드롭다운 버튼과 교환 버튼
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton<TranslateLanguage>(
                      value: _sourceLanguage,
                      onChanged: (TranslateLanguage? newValue) {
                        setState(() {
                          _sourceLanguage = newValue!;
                          onDeviceTranslator = OnDeviceTranslator(
                            sourceLanguage: _sourceLanguage,
                            targetLanguage: _targetLanguage,
                          );
                        });
                      },
                      items: TranslateLanguage.values
                          .map<DropdownMenuItem<TranslateLanguage>>((TranslateLanguage value) {
                        return DropdownMenuItem<TranslateLanguage>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_horiz),
                      onPressed: _switchLanguages,
                    ),
                    DropdownButton<TranslateLanguage>(
                      value: _targetLanguage,
                      onChanged: (TranslateLanguage? newValue) {
                        setState(() {
                          _targetLanguage = newValue!;
                          onDeviceTranslator = OnDeviceTranslator(
                            sourceLanguage: _sourceLanguage,
                            targetLanguage: _targetLanguage,
                          );
                        });
                      },
                      items: TranslateLanguage.values
                          .map<DropdownMenuItem<TranslateLanguage>>((TranslateLanguage value) {
                        return DropdownMenuItem<TranslateLanguage>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}