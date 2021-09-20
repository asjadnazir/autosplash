import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Uploader extends StatefulWidget {
  final File file;
  final File thumbFile;
  Uploader({Key key, this.file, this.thumbFile}) : super(key: key);
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://auto-splash.appspot.com');
  StorageUploadTask _uploadTask;

  void _startUpload() {
    String filePath = 'images/${DateTime.now()}.png';
    String thumbFilePath = 'images/thumb_images/${DateTime.now()}.png';
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
      _uploadTask =
          _storage.ref().child(thumbFilePath).putFile(widget.thumbFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _uploadTask != null
        ? StreamBuilder<StorageTaskEvent>(
            stream: _uploadTask.events,
            builder: (context, snapshot) {
              var event = snapshot?.data?.snapshot;
              double progressPrecent = event != null
                  ? event.bytesTransferred / event.totalByteCount
                  : 0;
              return Column(
                children: [
                  _uploadTask.isComplete ? Text('Hurrah!') : Offstage(),
                  _uploadTask.isPaused
                      ? FlatButton(
                          onPressed: _uploadTask.resume,
                          child: Icon(Icons.play_arrow))
                      : Offstage(),
                  _uploadTask.isInProgress
                      ? FlatButton(
                          onPressed: _uploadTask.pause,
                          child: Icon(Icons.pause))
                      : Offstage(),
                  LinearProgressIndicator(
                    value: progressPrecent,
                  ),
                  Text('${(progressPrecent * 100).toStringAsFixed(2)} %')
                ],
              );
            },
          )
        : FlatButton.icon(
            onPressed: _startUpload,
            icon: Icon(Icons.cloud_upload),
            label: Text('Upload to Firebse'),
          );
  }
}
