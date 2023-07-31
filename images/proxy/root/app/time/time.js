function utc(r) {
    r.return(200, new Date().toISOString());
}

export default {utc};
