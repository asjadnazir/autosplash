import 'dart:io';
import 'package:autosplash/models/user.dart';
import 'package:autosplash/services/database.dart';
import 'package:autosplash/shared/widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'dart:math' as Math;

import '../../constants.dart';

class UploadScreen extends StatefulWidget {
  static String routeName = '/upload';
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PickedFile imageUri;
  File _imageFile;
  File _thumpImageFile;
  final ImagePicker _picker = ImagePicker();

  //form
  final _fromKey = GlobalKey<FormState>();
  FocusNode _descFocus;
  String _title;
  String _desc;
  String _imgUrl;
  String _tagserror;
  List<String> tags = List();
  String _thumbImgUrl;

  //updoad
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://auto-splash.appspot.com');
  StorageUploadTask _uploadTask;
  StorageUploadTask _uploadThumbTask;
  String _uid;

  //stepper
  int currentStep = 0;
  bool complete = false;
  bool formStepComplete = false;

  bool _isFabVisible = true;

  _validate() async {
    if (_imageFile == null) {
      goTo(0);
      Flushbar(
        message: "Please Select image",
        duration: Duration(seconds: 3),
      )..show(context);
    } else if (_thumpImageFile == null) {
      Flushbar(
        message: "Something went wrong. try again.",
        duration: Duration(seconds: 3),
      )..show(context);
    } else if (!_fromKey.currentState.validate()) {
      goTo(1);
    } else if (tags.length < 2) {
      goTo(1);

      setState(() => _tagserror = 'Add atleast two tags');
    } else {
      setState(() {
        _isFabVisible = false;
        currentStep = 2;
      });
      _startUpload(_uid);
    }
  }

  void _startUpload(String uid) {
    _getThumbUrl().then((String result) {
      if (mounted)
        setState(() {
          _thumbImgUrl = result;
        });
      _getUrl().then((String result) {
        if (mounted)
          setState(() {
            _imgUrl = result;
          });
        tags.addAll(_title?.split(' '));
        _uploadImgData(uid).then((v) {
          print('Completed @Upload: Uploading');
          Navigator.of(context).pop();
        });
      });
    });
  }

  Future<void> _uploadImgData(String uid) async {
    await DatabaseService().uploadImg(
      '',
      uid,
      _title,
      _desc,
      tags,
      _imgUrl ?? '',
      _thumbImgUrl ?? '',
      null,
      '',
      0,
      0,
    );
  }

  Future<String> _getThumbUrl() async {
    String thumbFilePath = 'images/thumb_images/${DateTime.now()}.png';
    _uploadThumbTask =
        _storage.ref().child(thumbFilePath).putFile(_thumpImageFile);
    StorageTaskSnapshot taskSnapshot = await _uploadThumbTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _getUrl() async {
    String filePath = 'images/${DateTime.now()}.png';
    _uploadTask = _storage.ref().child(filePath).putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await _uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    print('Started @Upload: Image Picker');
    PickedFile selected = await _picker.getImage(source: source);
    // print('Picked byts');
    // print(File(selected?.path)?.lengthSync());
    if (selected != null)
      _cropImage(selected);
    else
      print('Error @Upload: Image picker return null');
  }

  Future<void> _cropImage(PickedFile selected) async {
    print('Started @Upload: Image Croper');
    File cropped = await ImageCropper.cropImage(
        sourcePath: selected.path,
        aspectRatio: CropAspectRatio(ratioX: 9.0, ratioY: 16.0),
        compressQuality: 100,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
          hideBottomControls: true,
          // initAspectRatio: CropAspectRatioPreset.original,
        ),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    // print('Cropped byts');
    // print(cropped?.lengthSync());
    if (cropped != null)
      _compressFile(cropped);
    else
      print('Error @Upload: Image compreser return null');
  }

  Future<void> _compressFile(File cropped) async {
    print('Started @Upload: Image Compresser');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(10000);
    // var compressed =
    await FlutterImageCompress.compressAndGetFile(
      cropped.absolute.path,
      '$path/img_$rand.jpg',
      quality: 10,
      format: CompressFormat.jpeg,
    ).then((value) => {
          if (mounted)
            setState(() {
              _thumpImageFile = value ?? _imageFile;
            })
        });
    if (_thumpImageFile == null) {
      print('Error @Upload: Image Compresser has some error');
    }

    if (mounted)
      setState(() {
        _imageFile = cropped ?? _imageFile;
        // print(_imageFile?.lengthSync());
        // print(_thumpImageFile?.lengthSync());
      });
  }

  next() {
    currentStep + 1 != 2
        ? goTo(currentStep + 1)
        : setState(() => complete = true);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    if (step != 2 && currentStep != 2) setState(() => currentStep = step);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    _uid = user.uid;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: new IconButton(
            splashColor: Colors.transparent,
            icon: new Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            InkWell(
                splashColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Icon(
                    Icons.file_upload,
                    color: Colors.transparent,
                  ),
                ),
                onTap: () {})
          ],
          title: brandName(),
        ),
        body: body(),
        // bottomNavigationBar: bottomAppBar(),
        floatingActionButton:
            Visibility(visible: _isFabVisible, child: _floatingActionButton()));
  }

  Container body() {
    return Container(
      child: Form(
        key: _fromKey,
        child: Stepper(
          steps: [
            Step(
              title: const Text('Photo'),
              isActive: currentStep == 0 ? true : false,
              state:
                  _imageFile == null ? StepState.editing : StepState.complete,
              content: AspectRatio(
                aspectRatio: 2 / 3,
                child: _imageFile != null
                    ? Image.file(
                        _imageFile,
                        fit: BoxFit.cover,
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Icon(FontAwesomeIcons.image,
                                  size: 50, color: Colors.black26),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Please select photo',
                              style: TextStyle(color: Colors.black38),
                            ),
                          )
                        ],
                      ),
              ),
            ),
            Step(
              isActive: currentStep == 1 ? true : false,
              state: formStepComplete ? StepState.complete : StepState.editing,
              title: const Text('Data'),
              content: Column(
                children: <Widget>[
                  SizedBox(height: 10.0),
                  TextFormField(
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_descFocus);
                    },
                    validator: (val) =>
                        val.isEmpty ? 'Please Enter a Title' : null,
                    onChanged: (val) => setState(() => _title = val),
                    decoration: _inputDecoration(hintText: 'Title', icon: null),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    focusNode: _descFocus,
                    validator: (val) =>
                        val.isEmpty ? 'Please Enter some Description' : null,
                    onChanged: (val) => setState(() => _desc = val),
                    decoration:
                        _inputDecoration(hintText: 'Description', icon: null),
                  ),
                  SizedBox(height: 10.0),
                  TextFieldTags(
                    tagsStyler: TagsStyler(
                        tagTextStyle: TextStyle(fontWeight: FontWeight.normal),
                        tagDecoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        tagCancelIcon: Icon(Icons.cancel,
                            size: 18.0, color: Colors.blue[900]),
                        tagPadding: const EdgeInsets.all(6.0)),
                    textFieldStyler: TextFieldStyler(
                      hintText: 'Tags',
                      helperText: null,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 8.0),
                      hintStyle: const TextStyle(fontSize: 18),
                      textFieldFocusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 2, color: Palette.darkBlue),
                      ),
                      textFieldEnabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Palette.darkBlue),
                      ),
                    ),
                    onTag: (tag) {
                      tags.add(tag);
                    },
                    onDelete: (tag) {
                      tags.remove(tag);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          _tagserror ?? '',
                          style: TextStyle(color: Palette.darkOrange),
                        )),
                  ),
                ],
              ),
            ),
            Step(
              title: Text('Uploading'),
              isActive: currentStep == 2 ? true : false,
              state:
                  _uploadTask == null ? StepState.editing : StepState.complete,
              content: _uploadTask != null ? _uploading() : Container(),
            )
          ],
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepContinue: next,
          onStepTapped: (step) => goTo(step),
          onStepCancel: cancel,
          controlsBuilder: (context, {onStepCancel, onStepContinue}) {
            return Container();
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String hintText, IconData icon}) {
    return InputDecoration(
      suffixIcon: Icon(
        icon,
        color: Palette.darkBlue,
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0),
      hintStyle: const TextStyle(fontSize: 18),
      hintText: hintText,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: Palette.darkBlue),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Palette.darkBlue),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Palette.darkOrange),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 2.0, color: Palette.darkOrange),
      ),
      errorStyle: const TextStyle(color: Palette.darkOrange),
    );
  }

  void _onAddPressed() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Color(0xFF737373),
          height: 120,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                )),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(FontAwesomeIcons.camera),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(FontAwesomeIcons.images),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  FloatingActionButton _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        currentStep == 1
            ? _validate()
            : _imageFile == null ? _onAddPressed() : goTo(1);
      },
      child: currentStep == 1
          ? Icon(Icons.file_upload)
          : _imageFile == null
              ? Icon(Icons.add_photo_alternate)
              : Icon(FontAwesomeIcons.chevronRight),
    );
  }

  Container _uploading() {
    print('Started @Upload: Uploading');
    return Container(
      child: StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;
          double progressPrecent =
              event != null ? event.bytesTransferred / event.totalByteCount : 0;
          if (_uploadTask.isComplete) {}

          return Center(
            child: Stack(
              children: <Widget>[
                Center(
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator(
                      // value: progress%,
                      strokeWidth: 10,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: Center(
                      child: Text(
                        '${(progressPrecent * 100).toStringAsFixed(2)} %',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontFamily: 'Overpass',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Container body1() {
//   return Container(
//     child: Stack(
//       children: [
//         Column(
//           children: <Widget>[
//             Expanded(
//               // flex: 3,
//               child: Container(
//                 padding: EdgeInsets.all(8),
//                 child: AspectRatio(
//                   aspectRatio: 2 / 3,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(6.0),
//                       border: Border.all(color: Colors.grey[300]),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(6.0),
//                       child: _imageFile != null
//                           ? Image.file(
//                               _imageFile,
//                               fit: BoxFit.cover,
//                             )
//                           : Container(
//                               color: Colors.grey[300],
//                               child: Icon(Icons.hourglass_empty),
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               // flex: 4,
//               child: Container(
//                   // padding: EdgeInsets.symmetric(horizontal: 20.0),
//                   // child: form(),
//                   ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Form form() {
//   return Form(
//     // key: _fromKey,
//     child: ListView(
//       children: <Widget>[
//         SizedBox(height: 10.0),
//         Text('Title'),
//         TextFormField(
//           validator: (val) => val.isEmpty ? 'Please Enter a Title' : null,
//           onChanged: (val) => setState(() => _title = val),
//           decoration: textInputDecoration,
//         ),
//         SizedBox(height: 10.0),
//         Text('Description'),
//         TextFormField(
//           validator: (val) =>
//               val.isEmpty ? 'Please Enter some Description' : null,
//           onChanged: (val) => setState(() => _desc = val),
//           decoration: textInputDecoration,
//         ),
//         SizedBox(height: 10.0),
//         Text('Tags'),
//         TextFormField(
//           validator: (val) =>
//               val.isEmpty ? 'Enter Keywords separated by comma.' : null,
//           onChanged: (val) => setState(() => _tags = val),
//           decoration: textInputDecoration,
//         ),
//       ],
//     ),
//   );
// }

// BottomAppBar bottomAppBar() {
//   return BottomAppBar(
//     child: Row(
//       children: <Widget>[
//         Expanded(
//           child: IconButton(
//             icon: Icon(Icons.photo_camera),
//             onPressed: () => _pickImage(ImageSource.camera),
//           ),
//         ),
//         Expanded(
//           child: IconButton(
//             icon: Icon(Icons.photo_library),
//             onPressed: () => _pickImage(ImageSource.gallery),
//           ),
//         ),
//       ],
//     ),
//   );
// }
