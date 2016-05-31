{
  'variables': {
    'name': 'cookpit',
  },
  'targets': [
    {
      'target_name': 'lib<(name)',
      'type': 'static_library',
      'conditions': [
        ['OS == "lib"', {
          'actions': [ {
            'action_name': 'clang-format',
            'type' : 'none',
            'inputs': [
            ],
            'outputs':[
            ],
            'action': [
              '$SRCROOT/utils/run_clang'
            ],
          },
          ],
        }],
      ],
      'dependencies': [
      ],
      'libraries': [
      ],
      'defines': [
      ],
      'cflags_cc': [
      ],
      'xcode_settings': {
        'OTHER_CFLAGS': [
        ],
        'OTHER_CPLUSPLUSFLAGS': [
        ],
      },
      'sources': [
        '<!@(python utils/glob.py -d cpp/src -i *.cpp *.hpp)'
      ],
      'include_dirs': [
        'vendors/flowcpp/include',
      ],
    },
    {
      'target_name': 'lib<(name)_ios',
      'type': 'static_library',
      'conditions': [],
      'dependencies': [
        'lib<(name)',
        'vendors/djinni/support-lib/support_lib.gyp:djinni_objc',
      ],
      'sources': [
        '<!@(python utils/glob.py -d ios/objc_gen -i *.mm *.h *.m)'
      ],
      'include_dirs': [],
    },
    {
      'target_name': 'lib<(name)_android',
      'type': 'shared_library',
      'dependencies': [
        'lib<(name)',
        'vendors/djinni/support-lib/support_lib.gyp:djinni_jni',
      ],
      'ldflags': [
        '-llog'
      ],
      'sources': [
        '<!@(python utils/glob.py -d android/jni_gen -i *.cpp *.hpp)',
      ],
      'include_dirs': [
        'cpp/src/gen'
      ],
    },
    {
      'target_name': 'test',
      'type': 'executable',
      'dependencies': [
        'lib<(name)',
        'vendors/googletest.gyp:googletest',
      ],
      'defines': [
      ],
      'xcode_settings': {
        'GCC_OPTIMIZATION_LEVEL': '0',
        'ONLY_ACTIVE_ARCH': 'YES',
        'ENABLE_TESTABILITY': 'YES',
      },
      'sources': [
        '<!@(python utils/glob.py -d cpp/test -i *.cpp *.hpp)',
      ],
      'include_dirs': [
        'vendors/googletest/googletest/include',
        'vendors/googletest/googlemock/include',
        'vendors/flowcpp/include',
      ],
    }
  ],
}
