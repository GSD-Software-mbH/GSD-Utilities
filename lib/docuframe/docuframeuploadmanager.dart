part of '../gsd_utilities.dart';

class DOCUframeUploadManager {
  final RestApiDOCUframeManager _restApiManager;
  late Duration progressCheckInterval;

  DOCUframeUploadManager(this._restApiManager,
      {this.progressCheckInterval = const Duration(seconds: 1)});

  Stream<GSDUploadProgress> uploadFiles(List<GSDUploadFile> files) async* {
    List<GSDUploadFileProgress> uploadFileProgresses = [];

    for (var file in files) {
      uploadFileProgresses.add(GSDUploadFileProgress(
        status: GSDUploadFileStatus.notStarted,
        uploadFile: file,
        uploadedBytes: 0,
      ));
    }

    GSDUploadProgress progress =
        GSDUploadProgress(uploadFileProgresses: uploadFileProgresses);

    int index = 0;

    for (var file in files) {
      await for (var fileProgress in _uploadFile(file)) {
        uploadFileProgresses[index] = fileProgress;
        yield progress;
      }

      index++;
    }

    yield progress;
  }

  Stream<GSDUploadFileProgress> _uploadFile(GSDUploadFile file,
      {String? replaceOID}) async* {
    yield GSDUploadFileProgress(
      status: GSDUploadFileStatus.inProgress,
      uploadFile: file,
      uploadedBytes: 0,
    );

    try {
      if (file.isImage && file.resolution != null && !kIsWeb) {
        String resizedImagePath =
            _resizeImage(file.filePath, file.resolution!.percentage);

        file.setPlatformFile(
            RestApiUploadFile.fromPath(path: resizedImagePath));
      }

      RestAPIFileUploadController controller =
          await _restApiManager.uploadFileWithController(file.platformFile,
              replaceOID: replaceOID ?? "");

      // try {
      //   await for (var progressUpdate in _monitorUploadProgress(file, controller)) {
      //     yield progressUpdate;
      //   }
      // } catch (_) {

      // }

      RestApiResponse response = await controller.result;

      if (response.isOk) {
        String oid =
            json.decode(response.httpResponse.body)['data']['~ObjectID'];

        yield GSDUploadFileProgress(
            status: GSDUploadFileStatus.completed,
            uploadFile: file,
            uploadedBytes: file.size,
            result:
                GSDUploadFileResult(uploadFile: file, success: true, oid: oid));
      } else {
        yield GSDUploadFileProgress(
          status: GSDUploadFileStatus.failed,
          uploadFile: file,
          uploadedBytes: file.size,
          result: GSDUploadFileResult(
              uploadFile: file,
              success: false,
              error: Exception(
                  "Upload failed with status code: ${response.httpResponse.statusCode}")),
        );
      }
    } catch (e) {
      yield GSDUploadFileProgress(
        status: GSDUploadFileStatus.failed,
        uploadFile: file,
        uploadedBytes: file.size,
        result: GSDUploadFileResult(
            uploadFile: file,
            success: false,
            error: e is Exception ? e : Exception(e)),
      );
    }
  }

  // Stream<GSDUploadFileProgress> _monitorUploadProgress(GSDUploadFile file, RestAPIFileUploadController controller) async* {
  //   bool uploadCompleted = false;

  //   controller.result.then((restApiResponse) {
  //     uploadCompleted = true;
  //   });

  //   while (!uploadCompleted) {
  //     try {
  //       await Future.delayed(progressCheckInterval);

  //       // Get upload progress from REST API
  //       RestApiResponse progressResponse = await _restApiManager.getUploadFile(controller.uploadId);

  //       if (progressResponse.isOk) {
  //         Map<String, dynamic> data = json.decode(progressResponse.httpResponse.body);
  //         int uploadedBytes = data['data']?['size'] ?? 0;

  //         yield GSDUploadFileProgress(status: GSDUploadFileStatus.inProgress, uploadFile: file, uploadedBytes: uploadedBytes);
  //       }
  //     } catch (e) {
  //       uploadCompleted = true;
  //     }
  //   }
  // }

  String _resizeImage(String imagePath, int percentage) {
    File originalFile = File(imagePath);
    img.Image originalImage = img.decodeImage(originalFile.readAsBytesSync())!;

    String originalName = basename(imagePath);

    // Calculate new dimensions based on the percentage
    int newWidth = (originalImage.width * percentage / 100).round();
    int newHeight = (originalImage.height * percentage / 100).round();

    // Resize the image
    img.Image resizedImage =
        img.copyResize(originalImage, width: newWidth, height: newHeight);

    // Save the resized image to a new file
    File resizedFile = File(
        '${originalFile.parent.path}/${newWidth}x${newHeight}_$originalName');
    resizedFile.writeAsBytesSync(
        img.encodeNamedImage(resizedFile.path, resizedImage) ?? [],
        flush: true);

    return resizedFile.path;
  }
}
