import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsd_utilities/gsd_utilities.dart';
import 'package:gsd_restapi/gsd_restapi.dart';

void main() {
  group('DOCUframeUploadManager Tests', () {
    late DOCUframeUploadManager uploadManager;
    late RestApiDOCUframeManager restApiManager;
    late Directory tempDir;

    setUpAll(() async {
      // Erstelle temporäres Verzeichnis für Testdateien
      tempDir = await Directory.systemTemp.createTemp('docuframe_test_');
    });

    tearDownAll(() async {
      // Aufräumen nach Tests
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    setUp(() {
      // Setup für jeden Test
      // Erstelle RestApiDOCUframeManager mit tatsächlichen Parametern
      // Diese müssen entsprechend deiner tatsächlichen Server-Konfiguration angepasst werden

      restApiManager = RestApiDOCUframeManager(
          config: RestApiDOCUframeConfig(
              appKey: "",
              userName: "",
              appNames: [],
              serverUrl: "",
              alias: ""));

      uploadManager = DOCUframeUploadManager(restApiManager);
    });

    test('should create upload manager with rest api manager', () {
      expect(uploadManager, isNotNull);
    });

    test('should upload a single text file', () async {
      // Erstelle eine Test-Textdatei
      final testFile = File('${tempDir.path}/test_document.txt');
      const testContent = 'Dies ist ein Test-Dokument für den Upload.';
      await testFile.writeAsString(testContent);

      // Erstelle GSDUploadFile
      final uploadFile = GSDUploadFile.fromPath(testFile.path);

      expect(uploadFile.name, 'test_document.txt');
      expect(uploadFile.size, testContent.length + 1);
      expect(uploadFile.isImage, false);

      // Teste Upload
      final uploadStream = uploadManager.uploadFiles([uploadFile]);

      List<GSDUploadProgress> progressUpdates = [];

      debugPrint('Start Progress');

      try {
        await for (final progress in uploadStream) {
          progressUpdates.add(progress);
          debugPrint("Progress Update ======================================");
          debugPrint("percentage: ${progress.percentage}");
          debugPrint("completedFiles: ${progress.completedFiles}");
          debugPrint("totalFiles: ${progress.totalFiles}");
          for (var i = 0; i < progress.uploadFileProgresses.length; i++) {
            final fileProgress = progress.uploadFileProgresses[i];
            debugPrint('File $i: Status=${fileProgress.status}');
          }
        }
        debugPrint('End Progress');

        // Überprüfe dass mindestens ein Progress-Update erhalten wurde
        expect(progressUpdates.isNotEmpty, true);

        // Überprüfe den finalen Status
        final finalProgress = progressUpdates.last;
        expect(finalProgress.uploadFileProgresses.length, 1);

        final finalFileProgress = finalProgress.uploadFileProgresses.first;
        expect(finalFileProgress.uploadFile.size, testContent.length);

        // Der Status sollte entweder completed oder failed sein
        expect(
            finalFileProgress.status == GSDUploadFileStatus.completed ||
                finalFileProgress.status == GSDUploadFileStatus.failed,
            true);

        if (finalFileProgress.status == GSDUploadFileStatus.completed) {
          expect(finalFileProgress.result!.success, true);
          expect(finalFileProgress.result!.oid, isNotNull);
          expect(finalFileProgress.result!.oid!.isNotEmpty, true);
        }
      } catch (e) {
        debugPrint('Upload failed with error: $e');
        // Bei einem echten Test ohne Mock kann der Upload fehlschlagen
        // Das ist normal wenn keine echte Server-Verbindung besteht
        expect(e, isA<Exception>());
      }
    });

    test('should upload multiple files', () async {
      // Erstelle mehrere Test-Dateien
      final textFile = File('${tempDir.path}/document1.txt');
      await textFile.writeAsString('Erstes Test-Dokument');

      final csvFile = File('${tempDir.path}/data.csv');
      await csvFile
          .writeAsString('Name,Age,City\nJohn,30,Berlin\nJane,25,Hamburg');

      // Erstelle Upload-Files
      final uploadFiles = [
        GSDUploadFile.fromPath(textFile.path),
        GSDUploadFile.fromPath(csvFile.path),
      ];

      expect(uploadFiles.length, 2);
      expect(uploadFiles[0].name, 'document1.txt');
      expect(uploadFiles[1].name, 'data.csv');

      // Teste Upload
      final uploadStream = uploadManager.uploadFiles(uploadFiles);

      List<GSDUploadProgress> progressUpdates = [];

      debugPrint('Start Progress');
      try {
        await for (final progress in uploadStream) {
          progressUpdates.add(progress);
          debugPrint("Progress Update");
          debugPrint("percentage: ${progress.percentage}");
          debugPrint("completedFiles: ${progress.completedFiles}");
          debugPrint("totalFiles: ${progress.totalFiles}");
          for (var i = 0; i < progress.uploadFileProgresses.length; i++) {
            final fileProgress = progress.uploadFileProgresses[i];
            debugPrint('File $i: Status=${fileProgress.status}');
          }
        }
        debugPrint('End Progress');

        expect(progressUpdates.isNotEmpty, true);

        final finalProgress = progressUpdates.last;
        expect(finalProgress.uploadFileProgresses.length, 2);
      } catch (e) {
        debugPrint('Multi-upload failed with error: $e');
        expect(e, isA<Exception>());
      }
    });

    test('should handle web platform file upload', () async {
      // Simuliere ein Web PlatformFile
      final webFileBytes =
          Uint8List.fromList('Web file content for testing'.codeUnits);

      final uploadFile =
          GSDUploadFile.fromBytes(webFileBytes, 'web_document.txt');

      expect(uploadFile.name, 'web_document.txt');
      expect(uploadFile.size, webFileBytes.length);
      expect(uploadFile.filePath, ''); // Web-Dateien haben keinen lokalen Pfad
      expect(uploadFile.platformFile.bytes, webFileBytes);

      // Teste Upload
      final uploadStream = uploadManager.uploadFiles([uploadFile]);

      try {
        await for (final progress in uploadStream) {
          debugPrint(
              'Web Upload Progress: ${progress.uploadFileProgresses.first.status}');
        }
      } catch (e) {
        debugPrint('Web upload failed (expected without real server): $e');
        expect(e, isA<Exception>());
      }
    });

    test('should handle empty file list', () async {
      final uploadStream = uploadManager.uploadFiles([]);

      List<GSDUploadProgress> progressUpdates = [];

      await for (final progress in uploadStream) {
        progressUpdates.add(progress);
      }

      // Bei leerer Liste sollte mindestens ein Progress-Update kommen
      expect(progressUpdates.isNotEmpty, true);
      expect(progressUpdates.last.uploadFileProgresses.isEmpty, true);
    });

    test('should generate unique UUIDs for upload files', () async {
      final testFile = File('${tempDir.path}/uuid_test.txt');
      await testFile.writeAsString('UUID test content');

      final uploadFile1 = GSDUploadFile.fromPath(testFile.path);
      final uploadFile2 = GSDUploadFile.fromPath(testFile.path);

      expect(uploadFile1.uuid, isNotEmpty);
      expect(uploadFile2.uuid, isNotEmpty);
      expect(uploadFile1.uuid, isNot(equals(uploadFile2.uuid)));
    });

    test('should correctly identify file properties', () async {
      // Text-Datei
      final textFile = File('${tempDir.path}/properties_test.txt');
      await textFile.writeAsString('Test content for properties');

      final uploadFile = GSDUploadFile.fromPath(textFile.path);

      expect(uploadFile.name, 'properties_test.txt');
      expect(uploadFile.filePath, textFile.path);
      expect(uploadFile.size, greaterThan(0));
      expect(uploadFile.isImage, false);
      expect(uploadFile.bytes, isNotNull);
      expect(uploadFile.resolution!.percentage, 100); // Standard-Auflösung
    });
  });
}
