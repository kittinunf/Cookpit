{
  'variables': {
    'deployment_target': '8.0',
    'warning_flags': [
      '-Wall',
      '-Wextra',
      '-Wno-extern-c-compat',
      '-Wno-missing-field-initializers',
      '-Wno-shorten-64-to-32',
    ],
  },
  'target_defaults': {
    'default_configuration': 'Debug',
    'android_unmangled_name': 1,
    'cflags': [
      '-Werror',
      '-gdwarf-2',
      '<(warning_flags)',
    ],
    'cflags_cc': [
      '-Werror',
      '-std=c++14',
      '-frtti',
      '-fexceptions',
      '<(warning_flags)',
    ],
    'xcode_settings': {
      'OTHER_CFLAGS' : ['<@(_cflags)'],
      'OTHER_CPLUSPLUSFLAGS' : ['<@(_cflags_cc)'],
      'CLANG_CXX_LANGUAGE_STANDARD': 'c++14',
      'CLANG_CXX_LIBRARY': 'libc++',
      'SKIP_INSTALL': 'YES',
      'CLANG_ENABLE_OBJC_ARC': 'YES',
      'COMBINE_HIDPI_IMAGES' : 'YES',
    },
    'conditions': [
      ['OS=="ios"', {
        'xcode_settings' : {
          'SDKROOT': 'iphoneos',
          'SUPPORTED_PLATFORMS': 'iphonesimulator iphoneos',
          'IPHONEOS_DEPLOYMENT_TARGET' : '<(deployment_target)',
        }
      }]
    ],
    'configurations': {
      'Debug': {
        'defines': [
          'DEBUG=1',
          'NDEBUG=0',
        ],
        'cflags': [
          '-DDEBUG',
          '-g',
          '-O0',
        ],
        'xcode_settings': {
          'GCC_OPTIMIZATION_LEVEL': '0',
          'ONLY_ACTIVE_ARCH': 'YES',
          'ENABLE_TESTABILITY': 'YES',
        },
      },
      'Release': {
        'defines': [
          'NDEBUG=1',
          'DEBUG=0',
        ],
        'cflags': [
          '-DNDEBUG',
          '-Os',
          '-fomit-frame-pointer',
          '-fdata-sections',
          '-ffunction-sections',
        ],
        'xcode_settings': {
          'DEAD_CODE_STRIPPING': 'YES',
        },
      },
    },
  },
}
