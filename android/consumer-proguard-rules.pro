# Keep the com.joyhonest.wifination package and all its classes and methods
-keep class com.joyhonest.wifination.** { *; }

# Keep native method names in all classes
-keepclassmembers class * {
    native <methods>;
}

# Keep classes with native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# If your plugin uses reflection or dynamic class loading, you might need additional rules
# For example, if methods are accessed via reflection, you should keep all members
-keepclassmembers class com.joyhonest.wifination.wifination {
    *;
}