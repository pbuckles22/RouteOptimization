# Test plan (TEST_PLAN.md)

**Default device ID:** Set in `script/test_integration.sh` as `DEFAULT_DEVICE_ID`, or pass as first argument: `./script/test_integration.sh <device_id>`. Get IDs with `flutter devices`.

**Two tiers:** Tier 1 = VM (`flutter test`). Tier 2 = simulator or device (`flutter test integration_test/ -d <id>`). Run both for full validation.

---

## Tier 1: Headless tests

```bash
flutter test --reporter expanded
# Or: ./script/test.sh
# Coverage: flutter test --coverage  or  ./script/test.sh --coverage
```

---

## Tier 2: Integration tests

Run on a simulator or device. Set `DEFAULT_DEVICE_ID` in `script/test_integration.sh` or pass it:

```bash
./script/test_integration.sh
# Or: ./script/test_integration.sh <device_id>
```

**Golden tests:** If you add golden tests, they use a 2% pixel-difference threshold (see `test/flutter_test_config.dart` and `integration_test/flutter_test_config.dart`). To update goldens: `flutter test integration_test/golden_test.dart -d <id> --update-goldens`.
