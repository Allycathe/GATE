--
-- PostgreSQL database dump
--

\restrict KujW6O9V1h7B3WgEZaxhLfA23rB789PSGpmXaZmDmBfQ6BXtxGe61viLEWsXFxD

-- Dumped from database version 15.18
-- Dumped by pg_dump version 15.18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: notify_nuevo_evento(); Type: FUNCTION; Schema: public; Owner: LAMEM
--

CREATE FUNCTION public.notify_nuevo_evento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM pg_notify(
    'nuevo_evento',
    row_to_json(NEW)::text  -- manda el payload de la fila como JSON
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_nuevo_evento() OWNER TO "LAMEM";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: crime_alert; Type: TABLE; Schema: public; Owner: LAMEM
--

CREATE TABLE public.crime_alert (
    id integer NOT NULL,
    triggered_at timestamp without time zone DEFAULT now(),
    center_supermarket_id integer,
    radius_km numeric(6,2) NOT NULL,
    time_window_h numeric(6,2) NOT NULL,
    report_count integer NOT NULL,
    report_ids integer[] NOT NULL
);


ALTER TABLE public.crime_alert OWNER TO "LAMEM";

--
-- Name: crime_alert_id_seq; Type: SEQUENCE; Schema: public; Owner: LAMEM
--

CREATE SEQUENCE public.crime_alert_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.crime_alert_id_seq OWNER TO "LAMEM";

--
-- Name: crime_alert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: LAMEM
--

ALTER SEQUENCE public.crime_alert_id_seq OWNED BY public.crime_alert.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: LAMEM
--

CREATE TABLE public.password_reset_tokens (
    id integer NOT NULL,
    id_user integer,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    used boolean DEFAULT false
);


ALTER TABLE public.password_reset_tokens OWNER TO "LAMEM";

--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: LAMEM
--

CREATE SEQUENCE public.password_reset_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.password_reset_tokens_id_seq OWNER TO "LAMEM";

--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: LAMEM
--

ALTER SEQUENCE public.password_reset_tokens_id_seq OWNED BY public.password_reset_tokens.id;


--
-- Name: report; Type: TABLE; Schema: public; Owner: LAMEM
--

CREATE TABLE public.report (
    id integer NOT NULL,
    id_thief integer,
    description text,
    date timestamp without time zone DEFAULT now(),
    image bytea,
    id_supermarket integer,
    face_descriptor jsonb,
    id_user integer
);


ALTER TABLE public.report OWNER TO "LAMEM";

--
-- Name: report_id_seq; Type: SEQUENCE; Schema: public; Owner: LAMEM
--

CREATE SEQUENCE public.report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.report_id_seq OWNER TO "LAMEM";

--
-- Name: report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: LAMEM
--

ALTER SEQUENCE public.report_id_seq OWNED BY public.report.id;


--
-- Name: supermarket; Type: TABLE; Schema: public; Owner: LAMEM
--

CREATE TABLE public.supermarket (
    id integer NOT NULL,
    name character varying NOT NULL,
    location_x double precision,
    location_y double precision
);


ALTER TABLE public.supermarket OWNER TO "LAMEM";

--
-- Name: supermarket_id_seq; Type: SEQUENCE; Schema: public; Owner: LAMEM
--

CREATE SEQUENCE public.supermarket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.supermarket_id_seq OWNER TO "LAMEM";

--
-- Name: supermarket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: LAMEM
--

ALTER SEQUENCE public.supermarket_id_seq OWNED BY public.supermarket.id;


--
-- Name: thief; Type: TABLE; Schema: public; Owner: LAMEM
--

CREATE TABLE public.thief (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.thief OWNER TO "LAMEM";

--
-- Name: thief_id_seq; Type: SEQUENCE; Schema: public; Owner: LAMEM
--

CREATE SEQUENCE public.thief_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.thief_id_seq OWNER TO "LAMEM";

--
-- Name: thief_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: LAMEM
--

ALTER SEQUENCE public.thief_id_seq OWNED BY public.thief.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: LAMEM
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying NOT NULL,
    last_name character varying NOT NULL,
    isadmin boolean DEFAULT false,
    email character varying NOT NULL,
    password character varying NOT NULL,
    id_supermarket integer
);


ALTER TABLE public.users OWNER TO "LAMEM";

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: LAMEM
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO "LAMEM";

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: LAMEM
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: crime_alert id; Type: DEFAULT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.crime_alert ALTER COLUMN id SET DEFAULT nextval('public.crime_alert_id_seq'::regclass);


--
-- Name: password_reset_tokens id; Type: DEFAULT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.password_reset_tokens ALTER COLUMN id SET DEFAULT nextval('public.password_reset_tokens_id_seq'::regclass);


--
-- Name: report id; Type: DEFAULT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.report ALTER COLUMN id SET DEFAULT nextval('public.report_id_seq'::regclass);


--
-- Name: supermarket id; Type: DEFAULT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.supermarket ALTER COLUMN id SET DEFAULT nextval('public.supermarket_id_seq'::regclass);


--
-- Name: thief id; Type: DEFAULT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.thief ALTER COLUMN id SET DEFAULT nextval('public.thief_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: crime_alert crime_alert_pkey; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.crime_alert
    ADD CONSTRAINT crime_alert_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_token_key UNIQUE (token);


--
-- Name: report report_pkey; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_pkey PRIMARY KEY (id);


--
-- Name: supermarket supermarket_pkey; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.supermarket
    ADD CONSTRAINT supermarket_pkey PRIMARY KEY (id);


--
-- Name: thief thief_pkey; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.thief
    ADD CONSTRAINT thief_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: crime_alert trg_nuevo_evento; Type: TRIGGER; Schema: public; Owner: LAMEM
--

CREATE TRIGGER trg_nuevo_evento AFTER INSERT ON public.crime_alert FOR EACH ROW EXECUTE FUNCTION public.notify_nuevo_evento();


--
-- Name: crime_alert crime_alert_center_supermarket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.crime_alert
    ADD CONSTRAINT crime_alert_center_supermarket_id_fkey FOREIGN KEY (center_supermarket_id) REFERENCES public.supermarket(id);


--
-- Name: password_reset_tokens password_reset_tokens_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: report report_id_supermarket_fkey; Type: FK CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_id_supermarket_fkey FOREIGN KEY (id_supermarket) REFERENCES public.supermarket(id);


--
-- Name: report report_id_thief_fkey; Type: FK CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_id_thief_fkey FOREIGN KEY (id_thief) REFERENCES public.thief(id);


--
-- Name: report report_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users users_id_supermarket_fkey; Type: FK CONSTRAINT; Schema: public; Owner: LAMEM
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_id_supermarket_fkey FOREIGN KEY (id_supermarket) REFERENCES public.supermarket(id);


--
-- PostgreSQL database dump complete
--

\unrestrict KujW6O9V1h7B3WgEZaxhLfA23rB789PSGpmXaZmDmBfQ6BXtxGe61viLEWsXFxD

