﻿Shader "Unlit/Textured With Detail"
{
    Properties
    {
        // _Tint ("Tint", Color) = (1, 1, 1, 1)
        // _MainTex ("Texture", 2D) = "white" {}
        // _DetailTex ("Detail Texture", 2D) = "gray" {}

        _MainTex ("Splat Map", 2D) = "white" {}
		[NoScaleOffset] _Texture1 ("Texture 1", 2D) = "white" {}
		[NoScaleOffset] _Texture2 ("Texture 2", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //float2 uvDetail : TEXCOORD1;
                float2 uvSplat : TEXCOORD1;
            };

            sampler2D _MainTex, _DetailTex;
			float4 _MainTex_ST, _DetailTex_ST;
            float4 _Tint;

            sampler2D _Texture1, _Texture2;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                o.uvSplat = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_MainTex, i.uv) * _Tint;
                // col *= tex2D(_DetailTex, i.uvDetail * 10) * 2;
                fixed4 col = tex2D(_MainTex, i.uv);
                float4 splat = tex2D(_MainTex, i.uvSplat);
                	return
					tex2D(_Texture1, i.uv) * splat.r +
					tex2D(_Texture2, i.uv) * (1 - splat.r);
            }
            ENDCG
        }
    }
}