Shader "Unlit/multiplelight"
{
    Properties
    {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _SpecularTint ("Specular", Color) = (0.5, 0.5, 0.5)
        _MainTex ("Albedo", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "My Lighting.cginc"

            ENDCG
        }

        Pass {
			Tags {
				"LightMode" = "ForwardAdd"
			}
            Blend One One
            ZWrite Off
			CGPROGRAM

			#pragma target 3.0

            #pragma multi_compile DIRECTIONAL POINT

			#pragma vertex vert
            #pragma fragment frag

            //#define POINT
			#include "My Lighting.cginc"

			ENDCG
		}
    }
}
