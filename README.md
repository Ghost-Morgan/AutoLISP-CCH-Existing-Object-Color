# CCH - Change Existing Object Color

An AutoLISP command for changing the color of selected AutoCAD objects. It complements `CC`, which only sets the current color for new objects.

## Use

Load `CCH_ColorChange.lsp` with `APPLOAD`, or add it to the Startup Suite. Preselect objects and run `CCH`, or run `CCH` and select objects when prompted. Choose a color using the same options as `CC`: `R`, `G`, `B`, `Y`, `W`, `C`, `M`, `8`, `9`, `LA` (ByLayer), or `K` (ByBlock).

The current version uses ActiveX to set each object's color within one undo mark. It reports changed and skipped object counts. Assigning an ACI color replaces an object's true-color override.

## Compatibility and status

Designed for AutoCAD/Civil 3D on Windows. The v2 implementation has been field-tested; verify cancel and single-undo behavior with the AutoCAD version and object types you use. Some Civil 3D objects may reject color changes.

## License

MIT. See [LICENSE](./LICENSE).
