Shader "cloudgenerator"
    {
        Properties
        {
            _rotate_projection("rotate projection", Vector) = (1, 0, 0, 0)
            _Noise_Scale("Noise Scale", Float) = 0
            _Noise_Speed("Noise Speed", Float) = 0.1
            _Noise_Height("Noise Height", Float) = 1
            _Noise_Remap("Noise Remap", Vector) = (0, 1, -1, 1)
            _Color_Peak("Color Peak", Color) = (1, 1, 1, 0)
            _Color_Valley("Color Valley", Color) = (0, 0, 0, 0)
            _Noise_Edge_1("Noise Edge 1", Float) = 0
            _Noise_Edge_2("Noise Edge 2", Float) = 1
            _Noise_Powerr("Noise Powerr", Float) = 2
            _Base_Scale("Base Scale", Float) = 5
            _Base_Speed("Base Speed", Float) = 0.2
            _Base_Strength("Base Strength", Float) = 2
            _Emission_Strength("Emission Strength", Float) = 2
            _Curveture_Radius("Curveture Radius", Float) = 0
            _Fersnel_Power("Fersnel Power", Float) = 1
            _Fresnel_Opacity("Fresnel Opacity", Float) = 1
            _Fade_Depth("Fade Depth", Float) = 100
            [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
            [HideInInspector]_QueueControl("_QueueControl", Float) = -1
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Transparent"
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalUnlitSubTarget"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    // LightMode: <None>
                }
            
            // Render State
            Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float3 viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 WorldSpaceViewDirection;
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float3 interp2 : INTERP2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyz =  input.viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.viewDirectionWS = input.interp2.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                {
                    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_c2b1249f018b4a51b29ec54e3a2e6b05_Out_0 = _Color_Valley;
                    float4 _Property_e8be25ff05dd46cebcfddf6f030307a6_Out_0 = _Color_Peak;
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float4 _Lerp_1e279c486117406280497affc61f74ea_Out_3;
                    Unity_Lerp_float4(_Property_c2b1249f018b4a51b29ec54e3a2e6b05_Out_0, _Property_e8be25ff05dd46cebcfddf6f030307a6_Out_0, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxxx), _Lerp_1e279c486117406280497affc61f74ea_Out_3);
                    float _Property_75500b619e954617bc91bf83c7f68c05_Out_0 = _Fersnel_Power;
                    float _FresnelEffect_d4cfacc9f4024006a06eb3dd6ba6685c_Out_3;
                    Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_75500b619e954617bc91bf83c7f68c05_Out_0, _FresnelEffect_d4cfacc9f4024006a06eb3dd6ba6685c_Out_3);
                    float _Multiply_ae7e31c9998e4eebaf440d6f96187a74_Out_2;
                    Unity_Multiply_float_float(_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2, _FresnelEffect_d4cfacc9f4024006a06eb3dd6ba6685c_Out_3, _Multiply_ae7e31c9998e4eebaf440d6f96187a74_Out_2);
                    float _Property_73d35b81f6c04750bfe68bfa3bc9ce41_Out_0 = _Fresnel_Opacity;
                    float _Multiply_bc20d508faad402eb54ad150d28574e8_Out_2;
                    Unity_Multiply_float_float(_Multiply_ae7e31c9998e4eebaf440d6f96187a74_Out_2, _Property_73d35b81f6c04750bfe68bfa3bc9ce41_Out_0, _Multiply_bc20d508faad402eb54ad150d28574e8_Out_2);
                    float4 _Add_2adbc53688884af28f4e20de61db709b_Out_2;
                    Unity_Add_float4(_Lerp_1e279c486117406280497affc61f74ea_Out_3, (_Multiply_bc20d508faad402eb54ad150d28574e8_Out_2.xxxx), _Add_2adbc53688884af28f4e20de61db709b_Out_2);
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.BaseColor = (_Add_2adbc53688884af28f4e20de61db709b_Out_2.xyz);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormalsOnly"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
                ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "SceneSelectionPass"
                Tags
                {
                    "LightMode" = "SceneSelectionPass"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENESELECTIONPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ScenePickingPass"
                Tags
                {
                    "LightMode" = "Picking"
                }
            
            // Render State
            Cull Back
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Transparent"
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalUnlitSubTarget"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    // LightMode: <None>
                }
            
            // Render State
            Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float3 viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 WorldSpaceViewDirection;
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float3 interp2 : INTERP2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyz =  input.viewDirectionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.viewDirectionWS = input.interp2.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                {
                    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_c2b1249f018b4a51b29ec54e3a2e6b05_Out_0 = _Color_Valley;
                    float4 _Property_e8be25ff05dd46cebcfddf6f030307a6_Out_0 = _Color_Peak;
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float4 _Lerp_1e279c486117406280497affc61f74ea_Out_3;
                    Unity_Lerp_float4(_Property_c2b1249f018b4a51b29ec54e3a2e6b05_Out_0, _Property_e8be25ff05dd46cebcfddf6f030307a6_Out_0, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxxx), _Lerp_1e279c486117406280497affc61f74ea_Out_3);
                    float _Property_75500b619e954617bc91bf83c7f68c05_Out_0 = _Fersnel_Power;
                    float _FresnelEffect_d4cfacc9f4024006a06eb3dd6ba6685c_Out_3;
                    Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_75500b619e954617bc91bf83c7f68c05_Out_0, _FresnelEffect_d4cfacc9f4024006a06eb3dd6ba6685c_Out_3);
                    float _Multiply_ae7e31c9998e4eebaf440d6f96187a74_Out_2;
                    Unity_Multiply_float_float(_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2, _FresnelEffect_d4cfacc9f4024006a06eb3dd6ba6685c_Out_3, _Multiply_ae7e31c9998e4eebaf440d6f96187a74_Out_2);
                    float _Property_73d35b81f6c04750bfe68bfa3bc9ce41_Out_0 = _Fresnel_Opacity;
                    float _Multiply_bc20d508faad402eb54ad150d28574e8_Out_2;
                    Unity_Multiply_float_float(_Multiply_ae7e31c9998e4eebaf440d6f96187a74_Out_2, _Property_73d35b81f6c04750bfe68bfa3bc9ce41_Out_0, _Multiply_bc20d508faad402eb54ad150d28574e8_Out_2);
                    float4 _Add_2adbc53688884af28f4e20de61db709b_Out_2;
                    Unity_Add_float4(_Lerp_1e279c486117406280497affc61f74ea_Out_3, (_Multiply_bc20d508faad402eb54ad150d28574e8_Out_2.xxxx), _Add_2adbc53688884af28f4e20de61db709b_Out_2);
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.BaseColor = (_Add_2adbc53688884af28f4e20de61db709b_Out_2.xyz);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormalsOnly"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
                ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "SceneSelectionPass"
                Tags
                {
                    "LightMode" = "SceneSelectionPass"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENESELECTIONPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ScenePickingPass"
                Tags
                {
                    "LightMode" = "Picking"
                }
            
            // Render State
            Cull Back
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 WorldSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float4 _rotate_projection;
                float _Noise_Scale;
                float _Noise_Speed;
                float _Noise_Height;
                float4 _Noise_Remap;
                float4 _Color_Peak;
                float4 _Color_Valley;
                float _Noise_Edge_1;
                float _Noise_Edge_2;
                float _Noise_Powerr;
                float _Base_Scale;
                float _Base_Speed;
                float _Base_Strength;
                float _Emission_Strength;
                float _Curveture_Radius;
                float _Fersnel_Power;
                float _Fresnel_Opacity;
                float _Fade_Depth;
                CBUFFER_END
                
                // Object and Global properties
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Power_float(float A, float B, out float Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
                {
                    Rotation = radians(Rotation);
                
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                    float one_minus_c = 1.0 - c;
                
                    Axis = normalize(Axis);
                
                    float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                              one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                              one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                            };
                
                    Out = mul(rot_mat,  In);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                {
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Absolute_float(float In, out float Out)
                {
                    Out = abs(In);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    if (unity_OrthoParams.w == 1.0)
                    {
                        Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                    }
                    else
                    {
                        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2;
                    Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2);
                    float _Property_2625958d46f0498eb5a47d84a90974d0_Out_0 = _Curveture_Radius;
                    float _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2;
                    Unity_Divide_float(_Distance_5ddf10ebcc814c7a9d6efcf2e294564a_Out_2, _Property_2625958d46f0498eb5a47d84a90974d0_Out_0, _Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2);
                    float _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2;
                    Unity_Power_float(_Divide_d955bbd6da8a4287bb21414f2577ac03_Out_2, 3, _Power_9e7075fe6f2b4692a07077c59130fde9_Out_2);
                    float3 _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2;
                    Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_9e7075fe6f2b4692a07077c59130fde9_Out_2.xxx), _Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2);
                    float _Property_87be9a77cb1948b1916427649b521062_Out_0 = _Noise_Edge_1;
                    float _Property_51d89622587e48448755b7db1eb36b36_Out_0 = _Noise_Edge_2;
                    float4 _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0 = _rotate_projection;
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_R_1 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[0];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_G_2 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[1];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_B_3 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[2];
                    float _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4 = _Property_761331f1a18e4bcda51b93956a1a8c47_Out_0[3];
                    float3 _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3;
                    Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_761331f1a18e4bcda51b93956a1a8c47_Out_0.xyz), _Split_07e4e2e379d640e3ac2794ecbb61f342_A_4, _RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3);
                    float _Property_69bf26e3f42249fe845404f0492c86b0_Out_0 = _Noise_Speed;
                    float _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_69bf26e3f42249fe845404f0492c86b0_Out_0, _Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2);
                    float2 _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_055cbeaf2b6b4278a1114f2a1cefc5cc_Out_2.xx), _TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3);
                    float _Property_14683977662b4a27959f644bd0115cb7_Out_0 = _Noise_Scale;
                    float _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_4e13850c7c724db4be2e37035620cc49_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2);
                    float2 _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3);
                    float _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_ac37b14e43a4481396cc0b0fbff1e75a_Out_3, _Property_14683977662b4a27959f644bd0115cb7_Out_0, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2);
                    float _Add_63b49f06960b492fa121a6bb897d87ff_Out_2;
                    Unity_Add_float(_GradientNoise_c3ef6db65ae941e39fbbb709403c58fe_Out_2, _GradientNoise_36a8d1dfe0f542bc9671884e16241080_Out_2, _Add_63b49f06960b492fa121a6bb897d87ff_Out_2);
                    float _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2;
                    Unity_Divide_float(_Add_63b49f06960b492fa121a6bb897d87ff_Out_2, 2, _Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2);
                    float _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1;
                    Unity_Saturate_float(_Divide_8f32a0ea09694ff0bb7d1c54d9aeae65_Out_2, _Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1);
                    float _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0 = _Noise_Powerr;
                    float _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2;
                    Unity_Power_float(_Saturate_341f0e0681064b8ea237fac96b3c1869_Out_1, _Property_7b20d9dcc38e44c7b6277129070d0a3a_Out_0, _Power_42a0e6e527174c9388ac9765ae7e298e_Out_2);
                    float4 _Property_0348a3423e964fd4b26198099721ddcc_Out_0 = _Noise_Remap;
                    float _Split_05e54157881a4dfcb4b65092c1b50562_R_1 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[0];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_G_2 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[1];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_B_3 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[2];
                    float _Split_05e54157881a4dfcb4b65092c1b50562_A_4 = _Property_0348a3423e964fd4b26198099721ddcc_Out_0[3];
                    float4 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4;
                    float3 _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5;
                    float2 _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_R_1, _Split_05e54157881a4dfcb4b65092c1b50562_G_2, 0, 0, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGBA_4, _Combine_c4c956d293da4e2d905eb08c1856e2de_RGB_5, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6);
                    float4 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4;
                    float3 _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5;
                    float2 _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6;
                    Unity_Combine_float(_Split_05e54157881a4dfcb4b65092c1b50562_B_3, _Split_05e54157881a4dfcb4b65092c1b50562_A_4, 0, 0, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGBA_4, _Combine_1f8e4f904a48482da2291596dcd2ab14_RGB_5, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6);
                    float _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3;
                    Unity_Remap_float(_Power_42a0e6e527174c9388ac9765ae7e298e_Out_2, _Combine_c4c956d293da4e2d905eb08c1856e2de_RG_6, _Combine_1f8e4f904a48482da2291596dcd2ab14_RG_6, _Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3);
                    float _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1;
                    Unity_Absolute_float(_Remap_1226b9c087f34f4a81aad24fd03706c6_Out_3, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1);
                    float _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3;
                    Unity_Smoothstep_float(_Property_87be9a77cb1948b1916427649b521062_Out_0, _Property_51d89622587e48448755b7db1eb36b36_Out_0, _Absolute_25f407270a9d4281b36377b6a61cdae4_Out_1, _Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3);
                    float _Property_09e6dcaf100f47769baec377321023ba_Out_0 = _Base_Speed;
                    float _Multiply_61f6253cd49042e09878fcf443b47233_Out_2;
                    Unity_Multiply_float_float(IN.TimeParameters.x, _Property_09e6dcaf100f47769baec377321023ba_Out_0, _Multiply_61f6253cd49042e09878fcf443b47233_Out_2);
                    float2 _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3;
                    Unity_TilingAndOffset_float((_RotateAboutAxis_ed782079e7f749acb1cbd3d311893898_Out_3.xy), float2 (1, 1), (_Multiply_61f6253cd49042e09878fcf443b47233_Out_2.xx), _TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3);
                    float _Property_38dd625578dd474391059956eddcaa0c_Out_0 = _Base_Scale;
                    float _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_cffdf81416ec4af08841903890d87d0b_Out_3, _Property_38dd625578dd474391059956eddcaa0c_Out_0, _GradientNoise_b3da15e89324438b90e116e26b590412_Out_2);
                    float _Property_6a805db987d64ba4b138ccc664199320_Out_0 = _Base_Strength;
                    float _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2;
                    Unity_Multiply_float_float(_GradientNoise_b3da15e89324438b90e116e26b590412_Out_2, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2);
                    float _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2;
                    Unity_Add_float(_Smoothstep_4b34c5f97d1c416487a6090eb52d99ef_Out_3, _Multiply_3e95b10a3e4841ac9d79e41c9d1ea289_Out_2, _Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2);
                    float _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2;
                    Unity_Add_float(1, _Property_6a805db987d64ba4b138ccc664199320_Out_0, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2);
                    float _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2;
                    Unity_Divide_float(_Add_86f9d095ab864ba2ac1857c92853ad2b_Out_2, _Add_bc9e4c7a54874f509e0b36af37051fcd_Out_2, _Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2);
                    float3 _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2;
                    Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_b9ebc34716e94af5a94a123cf6d20832_Out_2.xxx), _Multiply_123a5476f1eb408fa5b959613157f47c_Out_2);
                    float _Property_36dd96b5b73347fd940eed94f18ca53d_Out_0 = _Noise_Height;
                    float3 _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2;
                    Unity_Multiply_float3_float3(_Multiply_123a5476f1eb408fa5b959613157f47c_Out_2, (_Property_36dd96b5b73347fd940eed94f18ca53d_Out_0.xxx), _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2);
                    float3 _Add_8591279b32894071a2714ecec22fab94_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_821c4ad6deb146ad878467d2bd4674a9_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2);
                    float3 _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    Unity_Add_float3(_Multiply_63ecd91a8b5b45479bade879f2811fe0_Out_2, _Add_8591279b32894071a2714ecec22fab94_Out_2, _Add_4da58e0380bd4361a1601e47435290d1_Out_2);
                    description.Position = _Add_4da58e0380bd4361a1601e47435290d1_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1);
                    float4 _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0 = IN.ScreenPosition;
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_R_1 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[0];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_G_2 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[1];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_B_3 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[2];
                    float _Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4 = _ScreenPosition_761381f8c1b747de88be0142fbe98043_Out_0[3];
                    float _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2;
                    Unity_Subtract_float(_Split_624e2ef1d4e84cffaccdb2dee2bc2390_A_4, 1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2);
                    float _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2;
                    Unity_Subtract_float(_SceneDepth_1bbfbe643d524dd88aebdaf21c63bc5d_Out_1, _Subtract_b8757976afbc46bba44859fe7fb40fd0_Out_2, _Subtract_b6e2725ce29149229f3b0066943dd980_Out_2);
                    float _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0 = _Fade_Depth;
                    float _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2;
                    Unity_Divide_float(_Subtract_b6e2725ce29149229f3b0066943dd980_Out_2, _Property_a4eed5233a7b45acbcd441cc7ac5d456_Out_0, _Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2);
                    float _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    Unity_Saturate_float(_Divide_1509d9c41c9746d6a46b2d123dbcc9f8_Out_2, _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1);
                    surface.Alpha = _Saturate_e7c1ebd752464f12b4d2bae91c84a18b_Out_1;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
                    output.TimeParameters =                             _TimeParameters.xyz;
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
        }
        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
    }