<template>
    <div class="wsd">
        <header class="container">
            <hgroup>
                <h1>Web Share Demo</h1>
                <h2>
                    A simple demo/test of the possibilities of the Web Share
                    API.
                </h2>
            </hgroup>
        </header>

        <main class="container">
            <section v-for="item in canSharePayloads">
                <h2>{{ item.title }}</h2>

                <pre>{{ JSON.stringify(item.payload, null, 4) }}</pre>

                <client-only>
                    <button v-if="item.canShare" @click="share(item.payload)">
                        Share
                    </button>

                    <p v-else>
                        <strong>Cannot share: </strong> {{ item.reason }}
                    </p>
                </client-only>
            </section>
        </main>
    </div>
</template>

<script>
async function fileFromUrl(url) {
    const response = await fetch(url);

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }

    const blob = await response.blob();
    const fileName = url.split("/").pop();

    return new File([blob], fileName, { type: blob.type });
}

export default {
    data() {
        return {
            files: { doge: null, rickWebM: null, rickMp4: null, rickJpg: null },
        };
    },

    async mounted() {
        this.files.doge = await fileFromUrl("/assets/doge.jpg");
        this.files.rickWebM = await fileFromUrl("/assets/rick.webm");
        this.files.rickMp4 = await fileFromUrl("/assets/rick.mp4");
        this.files.rickJpg = await fileFromUrl("/assets/rick.jpg");
    },

    computed: {
        baseUrl() {
            if (process.client) {
                return window.location.origin;
            } else {
                return "";
            }
        },

        sharePayloads() {
            const out = [
                {
                    title: "Simple URL share",
                    payload: {
                        title: "MDN",
                        text: "Learn web development on MDN!",
                        url: "https://developer.mozilla.org",
                    },
                },
                {
                    title: "Image via URL share",
                    payload: {
                        title: "Doge",
                        text: "A picture of a doge",
                        url: `${this.baseUrl}/assets/doge.jpg`,
                    },
                },
                {
                    title: "MP4 Video via URL share",
                    payload: {
                        title: "Rick Astley - Never Gonna Give You Up",
                        text: "A video of Rick Astley",
                        url: `${this.baseUrl}/assets/rick.mp4`,
                    },
                },
            ];

            if (this.files.doge) {
                out.push({
                    title: "Image + Text share",
                    payload: {
                        title: "Doge",
                        text: "A picture of a doge",
                        files: [this.files.doge],
                    },
                });

                out.push({
                    title: "Image only share",
                    payload: {
                        files: [this.files.doge],
                    },
                });
            }

            if (this.files.rickWebM) {
                out.push({
                    title: "WebM Video share",
                    payload: {
                        title: "Rick Astley - Never Gonna Give You Up",
                        files: [this.files.rickWebM],
                    },
                });
            }

            if (this.files.rickMp4) {
                out.push({
                    title: "MP4 Video share",
                    payload: {
                        title: "Rick Astley - Never Gonna Give You Up",
                        files: [this.files.rickMp4],
                    },
                });
                out.push({
                    title: "MP4 Alone share",
                    payload: {
                        files: [this.files.rickMp4],
                    },
                });
                out.push({
                    title: "MP4 Video + Image share",
                    payload: {
                        title: "Rick Astley - Never Gonna Give You Up",
                        files: [this.files.rickMp4, this.files.rickJpg],
                    },
                });
            }

            return out;
        },

        canSharePayloads() {
            return this.sharePayloads.map((item) => {
                const canShare = this.canShare(item.payload);

                return {
                    ...item,
                    canShare: canShare === true,
                    reason: canShare !== true ? canShare : "",
                };
            });
        },
    },

    methods: {
        canShare(payload) {
            if (process.server) {
                return "No sharing server-side";
            }

            if (!window?.navigator?.canShare) {
                return "Share API not supported";
            }

            if (!navigator.canShare(payload)) {
                return "Cannot share this payload";
            }

            return true;
        },

        async share(payload) {
            try {
                await navigator.share(payload);
                console.log("Sharing done");
            } catch (e) {
                console.log(e);
            }
        },
    },
};
</script>

<style>
.wsd > footer,
.wsd > header,
.wsd > main {
    width: 100%;
    margin-right: auto;
    margin-left: auto;
    padding: var(--block-spacing-vertical) 0;
}
</style>
