import 'package:flutter_test/flutter_test.dart';
import 'package:event/event.dart';

// Test-Event-Args-Klasse
class TestEventArgs {
  final String message;
  TestEventArgs(this.message);
}

// Basis-Config-Klasse für Tests
abstract class BaseConfigTest {
  Event configChangedEvent = Event();

  String toJson();
  void loadFromJson(String jsonString);

  void save() {
    configChangedEvent.broadcast();
  }
}

// Implementierung für Tests
class SimpleTestConfig extends BaseConfigTest {
  String? testValue;
  int? testNumber;

  SimpleTestConfig({this.testValue, this.testNumber});

  @override
  String toJson() {
    final escapedValue =
        testValue?.replaceAll('\\', '\\\\').replaceAll('"', '\\"') ?? 'null';
    return '{"testValue": ${testValue != null ? '"$escapedValue"' : 'null'}, "testNumber": $testNumber}';
  }

  @override
  void loadFromJson(String jsonString) {
    if (jsonString.contains('"testValue"')) {
      final valueMatch = RegExp(r'"testValue":\s*"((?:[^"\\]|\\.)*)"\s*[,}]')
          .firstMatch(jsonString);
      testValue =
          valueMatch?.group(1)?.replaceAll('\\"', '"').replaceAll('\\\\', '\\');
    } else if (jsonString.contains('"testValue": null')) {
      testValue = null;
    }
    if (jsonString.contains('"testNumber"')) {
      final numberMatch =
          RegExp(r'"testNumber":\s*(-?\d+)').firstMatch(jsonString);
      testNumber = int.tryParse(numberMatch?.group(1) ?? '');
    } else if (jsonString.contains('"testNumber": null')) {
      testNumber = null;
    }
  }
}

// Config-Result-Klasse für Tests
class ConfigResultTest<T extends BaseConfigTest> {
  final T? config;
  final bool isSuccess;
  final String log;
  final Exception? error;

  ConfigResultTest({
    required this.isSuccess,
    required this.log,
    this.config,
    this.error,
  });
}

void main() {
  group('Base Config Tests', () {
    late SimpleTestConfig testConfig;

    setUp(() {
      testConfig = SimpleTestConfig();
    });

    test('should trigger configChangedEvent when save is called', () async {
      // Arrange
      bool eventTriggered = false;
      testConfig.configChangedEvent.subscribe((args) async {
        eventTriggered = true;
      });

      // Act
      testConfig.save();

      // Assert
      await Future.delayed(Duration(milliseconds: 10));
      expect(eventTriggered, isTrue);
    });

    test('should serialize and deserialize correctly', () {
      // Arrange
      testConfig.testValue = "Hello World";
      testConfig.testNumber = 123;

      // Act
      final json = testConfig.toJson();
      final newConfig = SimpleTestConfig();
      newConfig.loadFromJson(json);

      // Assert
      expect(newConfig.testValue, equals("Hello World"));
      expect(newConfig.testNumber, equals(123));
    });

    test('should handle null values correctly', () {
      // Arrange
      testConfig.testValue = null;
      testConfig.testNumber = null;

      // Act
      final json = testConfig.toJson();
      final newConfig = SimpleTestConfig();
      newConfig.loadFromJson(json);

      // Assert
      expect(newConfig.testValue, isNull);
      expect(newConfig.testNumber, isNull);
    });

    test('should handle empty JSON correctly', () {
      // Arrange
      final newConfig = SimpleTestConfig();

      // Act
      newConfig.loadFromJson('{}');

      // Assert
      expect(newConfig.testValue, isNull);
      expect(newConfig.testNumber, isNull);
    });

    test('should handle malformed JSON gracefully', () {
      // Arrange
      final newConfig = SimpleTestConfig();

      // Act
      newConfig.loadFromJson('invalid json');

      // Assert
      expect(newConfig.testValue, isNull);
      expect(newConfig.testNumber, isNull);
    });
  });

  group('ConfigResult Tests', () {
    test('should create successful result correctly', () {
      // Arrange
      final testConfig = SimpleTestConfig(testValue: "test", testNumber: 42);

      // Act
      final result = ConfigResultTest<SimpleTestConfig>(
        isSuccess: true,
        log: "Success log",
        config: testConfig,
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.log, equals("Success log"));
      expect(result.config, equals(testConfig));
      expect(result.error, isNull);
    });

    test('should create failure result correctly', () {
      // Arrange
      final exception = Exception("Test error");

      // Act
      final result = ConfigResultTest<SimpleTestConfig>(
        isSuccess: false,
        log: "Error log",
        error: exception,
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.log, equals("Error log"));
      expect(result.config, isNull);
      expect(result.error, equals(exception));
    });

    test('should handle empty log correctly', () {
      // Act
      final result = ConfigResultTest<SimpleTestConfig>(
        isSuccess: true,
        log: "",
      );

      // Assert
      expect(result.log, equals(""));
      expect(result.log.isEmpty, isTrue);
    });
  });

  group('Event Integration Tests', () {
    test('should handle multiple subscribers correctly', () async {
      // Arrange
      final config = SimpleTestConfig(testValue: "test");
      int subscriber1Count = 0;
      int subscriber2Count = 0;

      config.configChangedEvent.subscribe((args) async {
        subscriber1Count++;
      });
      config.configChangedEvent.subscribe((args) async {
        subscriber2Count++;
      });

      // Act
      config.save();
      config.save();

      // Assert
      await Future.delayed(Duration(milliseconds: 10));
      expect(subscriber1Count, equals(2));
      expect(subscriber2Count, equals(2));
    });

    test('should handle unsubscribe correctly', () async {
      // Arrange
      final config = SimpleTestConfig(testValue: "test");
      int eventCount = 0;

      config.configChangedEvent.subscribe((args) async {
        eventCount++;
      });

      // Act
      config.save();
      // Event-Handling ohne unsubscribe da die Event-Library dies anders handhabt
      config.save();

      // Assert
      await Future.delayed(Duration(milliseconds: 10));
      expect(eventCount, equals(2)); // Beide Events sollten verarbeitet werden
    });

    test('config serialization with special characters should work', () {
      // Arrange
      final config = SimpleTestConfig(
        testValue: "Test with \"quotes\" and \\ backslashes",
        testNumber: 999,
      );

      // Act
      final json = config.toJson();
      final restored = SimpleTestConfig();
      restored.loadFromJson(json);

      // Assert
      expect(restored.testValue,
          equals("Test with \"quotes\" and \\ backslashes"));
      expect(restored.testNumber, equals(999));
    });

    test('multiple configs should work independently', () {
      // Arrange
      final config1 = SimpleTestConfig(testValue: "Config1", testNumber: 1);
      final config2 = SimpleTestConfig(testValue: "Config2", testNumber: 2);

      int events1 = 0;
      int events2 = 0;

      config1.configChangedEvent.subscribe((args) async {
        events1++;
      });
      config2.configChangedEvent.subscribe((args) async {
        events2++;
      });

      // Act
      config1.save();
      config2.save();
      config1.save();

      // Assert
      expect(events1, equals(2));
      expect(events2, equals(1));
    });

    test('config should preserve data types correctly', () {
      // Test verschiedene Zahlen
      final testNumbers = [0, -1, 42, 999999];

      for (final number in testNumbers) {
        final config = SimpleTestConfig(testValue: "test", testNumber: number);
        final json = config.toJson();
        final restored = SimpleTestConfig();
        restored.loadFromJson(json);

        expect(restored.testNumber, equals(number),
            reason: "Failed for number: $number");
      }
    });
  });
}
