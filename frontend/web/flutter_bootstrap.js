{{flutter_js}}
{{flutter_build_config}}

// Configure Flutter to use URL path strategy (removes # from URLs)
_flutter.loader.load({
  config: {
    // Use path-based routing instead of hash-based routing
    // This removes the # from URLs and uses HTML5 History API
    usePathUrlStrategy: true,
  },
  onEntrypointLoaded: async function(engineInitializer) {
    let appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  }
});
